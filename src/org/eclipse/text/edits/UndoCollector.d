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
module org.eclipse.text.edits.UndoCollector;
import org.eclipse.text.edits.MalformedTreeException;
import org.eclipse.text.edits.TextEditGroup;
import org.eclipse.text.edits.RangeMarker;
import org.eclipse.text.edits.TextEditCopier;
import org.eclipse.text.edits.UndoEdit;
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
import org.eclipse.text.edits.ISourceModifier;
import org.eclipse.text.edits.CopyingRangeMarker;
import org.eclipse.text.edits.DeleteEdit;



import java.lang.all;
import java.util.Set;


import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.DocumentEvent;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IDocumentListener;


class UndoCollector : IDocumentListener {

    protected UndoEdit undo;

    package UndoEdit undo_package(){
        return undo;
    }

    private int fOffset;
    private int fLength;

    /**
     * @since 3.1
     */
    private String fLastCurrentText;

    public this(TextEdit root) {
        fOffset= root.getOffset();
        fLength= root.getLength();
    }

    public void connect(IDocument document) {
        document.addDocumentListener(this);
        undo= new UndoEdit();
    }

    public void disconnect(IDocument document) {
        if (undo !is null) {
            document.removeDocumentListener(this);
            undo.defineRegion(fOffset, fLength);
        }
    }

    public void documentChanged(DocumentEvent event) {
        fLength+= getDelta(event);
    }

    private static int getDelta(DocumentEvent event) {
        String text= event.getText();
        return text is null ? -event.getLength() : (text.length() - event.getLength());
    }

    public void documentAboutToBeChanged(DocumentEvent event) {
        int offset= event.getOffset();
        int currentLength= event.getLength();
        String currentText= null;
        try {
            currentText= event.getDocument().get(offset, currentLength);
        } catch (BadLocationException cannotHappen) {
            Assert.isTrue(false, "Can't happen"); //$NON-NLS-1$
        }

        /*
         * see https://bugs.eclipse.org/bugs/show_bug.cgi?id=93634
         * If the same string is replaced on many documents (e.g. rename
         * package), the size of the undo can be reduced by using the same
         * String instance in all edits, instead of using the unique String
         * returned from IDocument.get(int, int).
         */
        if (fLastCurrentText !is null && fLastCurrentText.equals(currentText))
            currentText= fLastCurrentText;
        else
            fLastCurrentText= currentText;

        String newText= event.getText();
        undo.add(new ReplaceEdit(offset, newText !is null ? newText.length() : 0, currentText));
    }
}
