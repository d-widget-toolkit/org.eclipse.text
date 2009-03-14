/*******************************************************************************
 * Copyright (c) 2000, 2006 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.jface.text.link.LinkedModeManager;
import org.eclipse.jface.text.link.LinkedModeModel;
import org.eclipse.jface.text.link.LinkedPosition;
import org.eclipse.jface.text.link.ILinkedModeListener;
import org.eclipse.jface.text.link.LinkedPositionGroup;
import org.eclipse.jface.text.link.InclusivePositionUpdater;



import java.lang.all;
import java.util.Stack;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.HashSet;







import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.text.IDocument;


/**
 * A linked mode manager ensures exclusive access of linked position infrastructures to documents. There
 * is at most one <code>LinkedModeManager</code> installed on the same document. The <code>getManager</code>
 * methods will return the existing instance if any of the specified documents already have an installed
 * manager.
 *
 * @since 3.0
 */
class LinkedModeManager {

    /**
     * Our implementation of <code>ILinkedModeListener</code>.
     */
    private class Listener : ILinkedModeListener {

        /*
         * @see org.eclipse.jdt.internal.ui.text.link2.LinkedModeModel.ILinkedModeListener#left(org.eclipse.jdt.internal.ui.text.link2.LinkedModeModel, int)
         */
        public void left(LinkedModeModel model, int flags) {
            this.outer.left(model, flags);
        }

        /*
         * @see org.eclipse.jdt.internal.ui.text.link2.LinkedModeModel.ILinkedModeListener#suspend(org.eclipse.jdt.internal.ui.text.link2.LinkedModeModel)
         */
        public void suspend(LinkedModeModel model) {
            // not interested
        }

        /*
         * @see org.eclipse.jdt.internal.ui.text.link2.LinkedModeModel.ILinkedModeListener#resume(org.eclipse.jdt.internal.ui.text.link2.LinkedModeModel, int)
         */
        public void resume(LinkedModeModel model, int flags) {
            // not interested
        }

    }

    /** Global map from documents to managers. */
    private static Map fgManagers_;
    private static Map fgManagers(){
        if( fgManagers_ is null ){
            synchronized( LinkedModeManager.classinfo ){
                if( fgManagers_ is null ){
                    fgManagers_= new HashMap();
                }
            }
        }
        return fgManagers_;
    }
    /**
     * Returns whether there exists a <code>LinkedModeManager</code> on <code>document</code>.
     *
     * @param document the document of interest
     * @return <code>true</code> if there exists a <code>LinkedModeManager</code> on <code>document</code>, <code>false</code> otherwise
     */
    public static bool hasManager(IDocument document) {
        return fgManagers.get(cast(Object)document) !is null;
    }

    /**
     * Returns whether there exists a <code>LinkedModeManager</code> on any of the <code>documents</code>.
     *
     * @param documents the documents of interest
     * @return <code>true</code> if there exists a <code>LinkedModeManager</code> on any of the <code>documents</code>, <code>false</code> otherwise
     */
    public static bool hasManager(IDocument[] documents) {
        for (int i= 0; i < documents.length; i++) {
            if (hasManager(documents[i]))
                return true;
        }
        return false;
    }

    /**
     * Returns the manager for the given documents. If <code>force</code> is
     * <code>true</code>, any existing conflicting managers are canceled, otherwise,
     * the method may return <code>null</code> if there are conflicts.
     *
     * @param documents the documents of interest
     * @param force whether to kill any conflicting managers
     * @return a manager able to cover the requested documents, or <code>null</code> if there is a conflict and <code>force</code> was set to <code>false</code>
     */
    public static LinkedModeManager getLinkedManager(IDocument[] documents, bool force) {
        if (documents is null || documents.length is 0)
            return null;

        Set mgrs= new HashSet();
        LinkedModeManager mgr= null;
        for (int i= 0; i < documents.length; i++) {
            mgr= cast(LinkedModeManager) fgManagers.get(cast(Object)documents[i]);
            if (mgr !is null)
                mgrs.add(mgr);
        }
        if (mgrs.size() > 1)
            if (force) {
                for (Iterator it= mgrs.iterator(); it.hasNext(); ) {
                    LinkedModeManager m= cast(LinkedModeManager) it.next();
                    m.closeAllEnvironments();
                }
            } else {
                return null;
            }

        if (mgrs.size() is 0)
            mgr= new LinkedModeManager();

        for (int i= 0; i < documents.length; i++)
            fgManagers.put(cast(Object)documents[i], mgr);

        return mgr;
    }

    /**
     * Cancels any linked mode manager for the specified document.
     *
     * @param document the document whose <code>LinkedModeManager</code> should be canceled
     */
    public static void cancelManager(IDocument document) {
        LinkedModeManager mgr= cast(LinkedModeManager) fgManagers.get(cast(Object)document);
        if (mgr !is null)
            mgr.closeAllEnvironments();
    }

    /** The hierarchy of environments managed by this manager. */
    private Stack fEnvironments;
    private Listener fListener;

    this(){
        fEnvironments= new Stack();
        fListener= new Listener();
    }

    /**
     * Notify the manager about a leaving model.
     *
     * @param model
     * @param flags
     */
    private void left(LinkedModeModel model, int flags) {
        if (!fEnvironments.contains(model))
            return;

        while (!fEnvironments.isEmpty()) {
            LinkedModeModel env= cast(LinkedModeModel) fEnvironments.pop();
            if (env is model)
                break;
            env.exit(ILinkedModeListener.NONE);
        }

        if (fEnvironments.isEmpty()) {
            removeManager();
        }
    }

    private void closeAllEnvironments() {
        while (!fEnvironments.isEmpty()) {
            LinkedModeModel env= cast(LinkedModeModel) fEnvironments.pop();
            env.exit(ILinkedModeListener.NONE);
        }

        removeManager();
    }

    private void removeManager() {
        for (Iterator it= fgManagers.keySet().iterator(); it.hasNext();) {
            IDocument doc= cast(IDocument) it.next();
            if (fgManagers.get(cast(Object)doc) is this)
                it.remove();
        }
    }

    /**
     * Tries to nest the given <code>LinkedModeModel</code> onto the top of
     * the stack of environments managed by the receiver. If <code>force</code>
     * is <code>true</code>, any environments on the stack that create a conflict
     * are killed.
     *
     * @param model the model to nest
     * @param force whether to force the addition of the model
     * @return <code>true</code> if nesting was successful, <code>false</code> otherwise (only possible if <code>force</code> is <code>false</code>
     */
    public bool nestEnvironment(LinkedModeModel model, bool force) {
        Assert.isNotNull(model);

        try {
            while (true) {
                if (fEnvironments.isEmpty()) {
                    model.addLinkingListener(fListener);
                    fEnvironments.push(model);
                    return true;
                }

                LinkedModeModel top= cast(LinkedModeModel) fEnvironments.peek();
                if (model.canNestInto(top)) {
                    model.addLinkingListener(fListener);
                    fEnvironments.push(model);
                    return true;
                } else if (!force) {
                    return false;
                } else { // force
                    fEnvironments.pop();
                    top.exit(ILinkedModeListener.NONE);
                    // continue;
                }
            }
        } finally {
            // if we remove any, make sure the new one got inserted
            Assert.isTrue(fEnvironments.size() > 0);
        }
    }

    /**
     * Returns the <code>LinkedModeModel</code> that is on top of the stack of
     * environments managed by the receiver.
     *
     * @return the topmost <code>LinkedModeModel</code>
     */
    public LinkedModeModel getTopEnvironment() {
        if (fEnvironments.isEmpty())
            return null;
        return cast(LinkedModeModel) fEnvironments.peek();
    }
}
