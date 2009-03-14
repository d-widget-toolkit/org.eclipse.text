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
module org.eclipse.text.edits.DeleteEdit;

import org.eclipse.text.edits.MultiTextEdit; // packageimport
import org.eclipse.text.edits.CopySourceEdit; // packageimport
import org.eclipse.text.edits.MoveSourceEdit; // packageimport
import org.eclipse.text.edits.CopyingRangeMarker; // packageimport
import org.eclipse.text.edits.ReplaceEdit; // packageimport
import org.eclipse.text.edits.EditDocument; // packageimport
import org.eclipse.text.edits.UndoCollector; // packageimport
import org.eclipse.text.edits.MoveTargetEdit; // packageimport
import org.eclipse.text.edits.CopyTargetEdit; // packageimport
import org.eclipse.text.edits.TextEditCopier; // packageimport
import org.eclipse.text.edits.ISourceModifier; // packageimport
import org.eclipse.text.edits.TextEditMessages; // packageimport
import org.eclipse.text.edits.TextEditProcessor; // packageimport
import org.eclipse.text.edits.MalformedTreeException; // packageimport
import org.eclipse.text.edits.TreeIterationInfo; // packageimport
import org.eclipse.text.edits.TextEditVisitor; // packageimport
import org.eclipse.text.edits.TextEditGroup; // packageimport
import org.eclipse.text.edits.TextEdit; // packageimport
import org.eclipse.text.edits.RangeMarker; // packageimport
import org.eclipse.text.edits.UndoEdit; // packageimport
import org.eclipse.text.edits.InsertEdit; // packageimport


import java.lang.all;
import java.util.Set;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;

/**
 * Text edit to delete a range in a document.
 * <p>
 * A delete edit is equivalent to <code>ReplaceEdit(
 * offset, length, "")</code>.
 *
 * @since 3.0
 */
public final class DeleteEdit : TextEdit {

    /**
     * Constructs a new delete edit.
     *
     * @param offset the offset of the range to replace
     * @param length the length of the range to replace
     */
    public this(int offset, int length) {
        super(offset, length);
    }

    /*
     * Copy constructor
     */
    private this(DeleteEdit other) {
        super(other);
    }

    /*
     * @see TextEdit#doCopy
     */
    protected TextEdit doCopy() {
        return new DeleteEdit(this);
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
        document.replace(getOffset(), getLength(), ""); //$NON-NLS-1$
        fDelta= -getLength();
        return fDelta;
    }

    /*
     * @see TextEdit#deleteChildren
     */
    bool deleteChildren() {
        return true;
    }
}
