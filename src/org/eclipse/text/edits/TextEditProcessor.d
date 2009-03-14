/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module org.eclipse.text.edits.TextEditProcessor;
import org.eclipse.text.edits.MalformedTreeException;
import org.eclipse.text.edits.TextEditGroup;
import org.eclipse.text.edits.RangeMarker;
import org.eclipse.text.edits.TextEditCopier;
import org.eclipse.text.edits.UndoEdit;
import org.eclipse.text.edits.InsertEdit;
import org.eclipse.text.edits.MoveSourceEdit;
import org.eclipse.text.edits.MoveTargetEdit;
import org.eclipse.text.edits.CopyTargetEdit;
import org.eclipse.text.edits.TextEditVisitor;
import org.eclipse.text.edits.TextEdit;
import org.eclipse.text.edits.TreeIterationInfo;
import org.eclipse.text.edits.TextEditMessages;
import org.eclipse.text.edits.CopySourceEdit;
import org.eclipse.text.edits.ReplaceEdit;
import org.eclipse.text.edits.MultiTextEdit;
import org.eclipse.text.edits.EditDocument;
import org.eclipse.text.edits.UndoCollector;
import org.eclipse.text.edits.ISourceModifier;
import org.eclipse.text.edits.CopyingRangeMarker;
import org.eclipse.text.edits.DeleteEdit;



import java.lang.all;
import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Set;




import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;


/**
 * A <code>TextEditProcessor</code> manages a set of edits and applies
 * them as a whole to an <code>IDocument</code>.
 * <p>
 * This class isn't intended to be subclassed.</p>
 *
 * @see org.eclipse.text.edits.TextEdit#apply(IDocument)
 *
 * @since 3.0
 * @noextend This class is not intended to be subclassed by clients.
 */
public class TextEditProcessor {

    private IDocument fDocument;
    private TextEdit fRoot;
    private int fStyle;

    private bool fChecked;
    private MalformedTreeException fException;

    private List fSourceEdits;

    /**
     * Constructs a new edit processor for the given
     * document.
     *
     * @param document the document to manipulate
     * @param root the root of the text edit tree describing
     *  the modifications. By passing a text edit a a text edit
     *  processor the ownership of the edit is transfered to the
     *  text edit processors. Clients must not modify the edit
     *  (e.g adding new children) any longer.
     *
     * @param style {@link TextEdit#NONE}, {@link TextEdit#CREATE_UNDO} or {@link TextEdit#UPDATE_REGIONS})
     */
    public this(IDocument document, TextEdit root, int style) {
        this(document, root, style, false);
    }

    private this(IDocument document, TextEdit root, int style, bool secondary) {
        Assert.isNotNull(cast(Object)document);
        Assert.isNotNull(root);
        fDocument= document;
        fRoot= root;
        if ( auto mte = cast(MultiTextEdit)fRoot )
            mte.defineRegion(0);
        fStyle= style;
        if (secondary) {
            fChecked= true;
            fSourceEdits= new ArrayList();
        }
    }

    /**
     * Creates a special internal processor used to during source computation inside
     * move source and copy source edits
     *
     * @param document the document to be manipulated
     * @param root the edit tree
     * @param style {@link TextEdit#NONE}, {@link TextEdit#CREATE_UNDO} or {@link TextEdit#UPDATE_REGIONS})
     * @return a secondary text edit processor
     * @since 3.1
     */
    static TextEditProcessor createSourceComputationProcessor(IDocument document, TextEdit root, int style) {
        return new TextEditProcessor(document, root, style, true);
    }

    /**
     * Returns the document to be manipulated.
     *
     * @return the document
     */
    public IDocument getDocument() {
        return fDocument;
    }

    /**
     * Returns the edit processor's root edit.
     *
     * @return the processor's root edit
     */
    public TextEdit getRoot() {
        return fRoot;
    }

    /**
     * Returns the style bits of the text edit processor
     *
     * @return the style bits
     * @see TextEdit#CREATE_UNDO
     * @see TextEdit#UPDATE_REGIONS
     */
    public int getStyle() {
        return fStyle;
    }

    /**
     * Checks if the processor can execute all its edits.
     *
     * @return <code>true</code> if the edits can be executed. Return  <code>false
     *  </code>otherwise. One major reason why edits cannot be executed are wrong
     *  offset or length values of edits. Calling perform in this case will very
     *  likely end in a <code>BadLocationException</code>.
     */
    public bool canPerformEdits() {
        try {
            fRoot.dispatchCheckIntegrity(this);
            fChecked= true;
        } catch (MalformedTreeException e) {
            fException= e;
            return false;
        }
        return true;
    }

    /**
     * Executes the text edits.
     *
     * @return an object representing the undo of the executed edits
     * @exception MalformedTreeException is thrown if the edit tree isn't
     *  in a valid state. This exception is thrown before any edit is executed.
     *  So the document is still in its original state.
     * @exception BadLocationException is thrown if one of the edits in the
     *  tree can't be executed. The state of the document is undefined if this
     *  exception is thrown.
     */
    public UndoEdit performEdits()  {
        if (!fChecked) {
            fRoot.dispatchCheckIntegrity(this);
        } else {
            if (fException !is null)
                throw fException;
        }
        return fRoot.dispatchPerformEdits(this);
    }

    /*
     * Class isn't intended to be sub-lcassed
     */
    protected bool considerEdit(TextEdit edit) {
        return true;
    }
    package bool considerEdit_package(TextEdit edit) {
        return considerEdit(edit);
    }


    //---- checking --------------------------------------------------------------------

    void checkIntegrityDo()  {
        fSourceEdits= new ArrayList();
        fRoot.traverseConsistencyCheck(this, fDocument, fSourceEdits);
        if (fRoot.getExclusiveEnd() > fDocument.getLength())
            throw new MalformedTreeException(null, fRoot, TextEditMessages.getString("TextEditProcessor.invalid_length")); //$NON-NLS-1$
    }

    void checkIntegrityUndo() {
        if (fRoot.getExclusiveEnd() > fDocument.getLength())
            throw new MalformedTreeException(null, fRoot, TextEditMessages.getString("TextEditProcessor.invalid_length")); //$NON-NLS-1$
    }

    //---- execution --------------------------------------------------------------------

    UndoEdit executeDo()  {
        UndoCollector collector= new UndoCollector(fRoot);
        try {
            if (createUndo())
                collector.connect(fDocument);
            computeSources();
            fRoot.traverseDocumentUpdating(this, fDocument);
            if (updateRegions()) {
                fRoot.traverseRegionUpdating(this, fDocument, 0, false);
            }
        } finally {
            collector.disconnect(fDocument);
        }
        return collector.undo_package;
    }

    private void computeSources() {
        for (Iterator iter= fSourceEdits.iterator(); iter.hasNext();) {
            List list= cast(List)iter.next();
            if (list !is null) {
                for (Iterator edits= list.iterator(); edits.hasNext();) {
                    TextEdit edit= cast(TextEdit)edits.next();
                    edit.traverseSourceComputation(this, fDocument);
                }
            }
        }
    }

    UndoEdit executeUndo()  {
        UndoCollector collector= new UndoCollector(fRoot);
        try {
            if (createUndo())
                collector.connect(fDocument);
            TextEdit[] edits= fRoot.getChildren();
            for (int i= edits.length - 1; i >= 0; i--) {
                edits[i].performDocumentUpdating(fDocument);
            }
        } finally {
            collector.disconnect(fDocument);
        }
        return collector.undo_package;
    }

    private bool createUndo() {
        return (fStyle & TextEdit.CREATE_UNDO) !is 0;
    }

    private bool updateRegions() {
        return (fStyle & TextEdit.UPDATE_REGIONS) !is 0;
    }
}
