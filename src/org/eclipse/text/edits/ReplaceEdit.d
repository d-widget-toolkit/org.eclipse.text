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
module org.eclipse.text.edits.ReplaceEdit;
import org.eclipse.text.edits.TextEditVisitor;
import org.eclipse.text.edits.TextEdit;



import java.lang.all;
import java.util.Set;


import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;

/**
 * Text edit to replace a range in a document with a different
 * string.
 *
 * @since 3.0
 */
public final class ReplaceEdit : TextEdit {

    private String fText;

    /**
     * Constructs a new replace edit.
     *
     * @param offset the offset of the range to replace
     * @param length the length of the range to replace
     * @param text the new text
     */
    public this(int offset, int length, String text) {
        super(offset, length);
        Assert.isNotNull(text);
        fText= text;
    }

    /*
     * Copy constructor
     *
     * @param other the edit to copy from
     */
    private this(ReplaceEdit other) {
        super(other);
        fText= other.fText;
    }

    /**
     * Returns the new text replacing the text denoted
     * by the edit.
     *
     * @return the edit's text.
     */
    public String getText() {
        return fText;
    }

    /*
     * @see TextEdit#doCopy
     */
    protected TextEdit doCopy() {
        return new ReplaceEdit(this);
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
        document.replace(getOffset(), getLength(), fText);
        fDelta= fText.length() - getLength();
        return fDelta;
    }

    /*
     * @see TextEdit#deleteChildren
     */
    bool deleteChildren() {
        return true;
    }

    /*
     * @see org.eclipse.text.edits.TextEdit#internalToString(java.lang.StringBuffer, int)
     * @since 3.3
     */
    void internalToString(StringBuffer buffer, int indent) {
        super.internalToString(buffer, indent);
        buffer.append(" <<").append(fText); //$NON-NLS-1$
    }
}
