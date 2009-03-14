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
module org.eclipse.text.edits.CopyingRangeMarker;

import org.eclipse.text.edits.MultiTextEdit; // packageimport
import org.eclipse.text.edits.CopySourceEdit; // packageimport
import org.eclipse.text.edits.MoveSourceEdit; // packageimport
import org.eclipse.text.edits.ReplaceEdit; // packageimport
import org.eclipse.text.edits.EditDocument; // packageimport
import org.eclipse.text.edits.UndoCollector; // packageimport
import org.eclipse.text.edits.DeleteEdit; // packageimport
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
 * A <code>CopyingRangeMarker</code> can be used to track positions when executing
 * text edits. Additionally a copying range marker stores a local copy of the
 * text it captures when it gets executed.
 *
 * @since 3.0
 */
public final class CopyingRangeMarker : TextEdit {

    private String fText;

    /**
     * Creates a new <tt>CopyRangeMarker</tt> for the given
     * offset and length.
     *
     * @param offset the marker's offset
     * @param length the marker's length
     */
    public this(int offset, int length) {
        super(offset, length);
    }

    /*
     * Copy constructor
     */
    private this(CopyingRangeMarker other) {
        super(other);
        fText= other.fText;
    }

    /*
     * @see TextEdit#doCopy
     */
    protected TextEdit doCopy() {
        return new CopyingRangeMarker(this);
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
        fText= document.get(getOffset(), getLength());
        fDelta= 0;
        return fDelta;
    }

    /*
     * @see TextEdit#deleteChildren
     */
    bool deleteChildren() {
        return false;
    }
}
