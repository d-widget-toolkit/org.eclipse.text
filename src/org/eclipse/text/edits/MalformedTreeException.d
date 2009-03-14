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
module org.eclipse.text.edits.MalformedTreeException;

import org.eclipse.text.edits.MultiTextEdit; // packageimport
import org.eclipse.text.edits.CopySourceEdit; // packageimport
import org.eclipse.text.edits.MoveSourceEdit; // packageimport
import org.eclipse.text.edits.CopyingRangeMarker; // packageimport
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
import org.eclipse.text.edits.TreeIterationInfo; // packageimport
import org.eclipse.text.edits.TextEditVisitor; // packageimport
import org.eclipse.text.edits.TextEditGroup; // packageimport
import org.eclipse.text.edits.TextEdit; // packageimport
import org.eclipse.text.edits.RangeMarker; // packageimport
import org.eclipse.text.edits.UndoEdit; // packageimport
import org.eclipse.text.edits.InsertEdit; // packageimport


import java.lang.all;
import java.util.Set;

/**
 * Thrown to indicate that an edit got added to a parent edit
 * but the child edit somehow conflicts with the parent or
 * one of it siblings.
 * <p>
 * This class is not intended to be serialized.
 * </p>
 *
 * @see TextEdit#addChild(TextEdit)
 * @see TextEdit#addChildren(TextEdit[])
 *
 * @since 3.0
 */
public class MalformedTreeException : RuntimeException {

    // Not intended to be serialized
    private static const long serialVersionUID= 1L;

    private TextEdit fParent;
    private TextEdit fChild;

    /**
     * Constructs a new malformed tree exception.
     *
     * @param parent the parent edit
     * @param child the child edit
     * @param message the detail message
     */
    public this(TextEdit parent, TextEdit child, String message) {
        super(message);
        fParent= parent;
        fChild= child;
    }

    /**
     * Returns the parent edit that caused the exception.
     *
     * @return the parent edit
     */
    public TextEdit getParent() {
        return fParent;
    }

    /**
     * Returns the child edit that caused the exception.
     *
     * @return the child edit
     */
    public TextEdit getChild() {
        return fChild;
    }

    void setParent(TextEdit parent) {
        fParent= parent;
    }
}
