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
module org.eclipse.text.edits.UndoEdit;
import org.eclipse.text.edits.MalformedTreeException;
import org.eclipse.text.edits.TextEditGroup;
import org.eclipse.text.edits.RangeMarker;
import org.eclipse.text.edits.TextEditCopier;
import org.eclipse.text.edits.InsertEdit;
import org.eclipse.text.edits.MoveSourceEdit;
import org.eclipse.text.edits.MoveTargetEdit;
import org.eclipse.text.edits.CopyTargetEdit;
import org.eclipse.text.edits.TextEditProcessor;
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
import java.util.Set;



import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;


/**
 * This class encapsulates the reverse changes of an executed text
 * edit tree. To apply an undo memento to a document use method
 * <code>apply(IDocument)</code>.
 * <p>
 * Clients can't add additional children to an undo edit nor can they
 * add an undo edit as a child to another edit. Doing so results in
 * both cases in a <code>MalformedTreeException<code>.
 *
 * @since 3.0
 * @noinstantiate This class is not intended to be instantiated by clients.
 */
public final class UndoEdit : TextEdit {

    this() {
        super(0, Integer.MAX_VALUE);
    }

    private this(UndoEdit other) {
        super(other);
    }

    /*
     * @see org.eclipse.text.edits.TextEdit#internalAdd(org.eclipse.text.edits.TextEdit)
     */
    void internalAdd(TextEdit child)  {
        throw new MalformedTreeException(null, this, TextEditMessages.getString("UndoEdit.no_children")); //$NON-NLS-1$
    }

    /*
     * @see org.eclipse.text.edits.MultiTextEdit#aboutToBeAdded(org.eclipse.text.edits.TextEdit)
     */
    void aboutToBeAdded(TextEdit parent) {
        throw new MalformedTreeException(parent, this, TextEditMessages.getString("UndoEdit.can_not_be_added")); //$NON-NLS-1$
    }

    UndoEdit dispatchPerformEdits(TextEditProcessor processor)  {
        return processor.executeUndo();
    }

    void dispatchCheckIntegrity(TextEditProcessor processor)  {
        processor.checkIntegrityUndo();
    }

    /*
     * @see org.eclipse.text.edits.TextEdit#doCopy()
     */
    protected TextEdit doCopy() {
        return new UndoEdit(this);
    }

    /*
     * @see TextEdit#accept0
     */
    protected void accept0(TextEditVisitor visitor) {
        bool visitChildren= visitor.visit(this);
        if (visitChildren) {
            acceptChildren(visitor);
        }
    }

    /*
     * @see TextEdit#performDocumentUpdating
     */
    int performDocumentUpdating(IDocument document)  {
        fDelta= 0;
        return fDelta;
    }

    void add(ReplaceEdit edit) {
        List children= internalGetChildren();
        if (children is null) {
            children= new ArrayList(2);
            internalSetChildren(children);
        }
        children.add(edit);
    }

    void defineRegion(int offset, int length) {
        internalSetOffset(offset);
        internalSetLength(length);
    }

    bool deleteChildren() {
        return false;
    }
}

