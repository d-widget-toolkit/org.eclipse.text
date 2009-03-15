/*******************************************************************************
 * Copyright (c) 2006 IBM Corporation and others.
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
module org.eclipse.jface.text.RewriteSessionEditProcessor;
import org.eclipse.jface.text.IRepairableDocument;
import org.eclipse.jface.text.AbstractDocument;
import org.eclipse.jface.text.IDocumentPartitionerExtension3;
import org.eclipse.jface.text.ConfigurableLineTracker;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.TypedRegion;
import org.eclipse.jface.text.IDocumentExtension2;
import org.eclipse.jface.text.TypedPosition;
import org.eclipse.jface.text.SlaveDocumentEvent;
import org.eclipse.jface.text.IDocumentExtension3;
import org.eclipse.jface.text.IDocumentListener;
import org.eclipse.jface.text.ISynchronizable;
import org.eclipse.jface.text.DocumentEvent;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.IRepairableDocumentExtension;
import org.eclipse.jface.text.DocumentRewriteSessionType;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.IDocumentExtension4;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.TextMessages;
import org.eclipse.jface.text.IDocumentPartitioningListenerExtension2;
import org.eclipse.jface.text.IDocumentInformationMappingExtension;
import org.eclipse.jface.text.IDocumentPartitioningListenerExtension;
import org.eclipse.jface.text.ITextStore;
import org.eclipse.jface.text.IDocumentPartitionerExtension;
import org.eclipse.jface.text.DocumentRewriteSession;
import org.eclipse.jface.text.IPositionUpdater;
import org.eclipse.jface.text.ISlaveDocumentManagerExtension;
import org.eclipse.jface.text.ILineTracker;
import org.eclipse.jface.text.ListLineTracker;
import org.eclipse.jface.text.IDocumentInformationMapping;
import org.eclipse.jface.text.IDocumentRewriteSessionListener;
import org.eclipse.jface.text.AbstractLineTracker;
import org.eclipse.jface.text.DefaultLineTracker;
import org.eclipse.jface.text.BadPositionCategoryException;
import org.eclipse.jface.text.BadPartitioningException;
import org.eclipse.jface.text.SequentialRewriteTextStore;
import org.eclipse.jface.text.IDocumentInformationMappingExtension2;
import org.eclipse.jface.text.DocumentPartitioningChangedEvent;
import org.eclipse.jface.text.FindReplaceDocumentAdapter;
import org.eclipse.jface.text.TextUtilities;
import org.eclipse.jface.text.ISlaveDocumentManager;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ILineTrackerExtension;
import org.eclipse.jface.text.IDocumentPartitioner;
import org.eclipse.jface.text.GapTextStore;
import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.IDocumentExtension;
import org.eclipse.jface.text.IDocumentPartitioningListener;
import org.eclipse.jface.text.CopyOnWriteTextStore;
import org.eclipse.jface.text.DefaultPositionUpdater;
import org.eclipse.jface.text.Line;
import org.eclipse.jface.text.DocumentRewriteSessionEvent;
import org.eclipse.jface.text.IDocumentPartitionerExtension2;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.TreeLineTracker;



import java.lang.all;

import org.eclipse.text.edits.CopyTargetEdit;
import org.eclipse.text.edits.DeleteEdit;
import org.eclipse.text.edits.InsertEdit;
import org.eclipse.text.edits.MalformedTreeException;
import org.eclipse.text.edits.MoveTargetEdit;
import org.eclipse.text.edits.ReplaceEdit;
import org.eclipse.text.edits.TextEdit;
import org.eclipse.text.edits.TextEditProcessor;
import org.eclipse.text.edits.TextEditVisitor;
import org.eclipse.text.edits.UndoEdit;

/**
 * A text edit processor that brackets the application of edits into a document rewrite session.
 *
 * @since 3.3
 */
public final class RewriteSessionEditProcessor : TextEditProcessor {
    /** The threshold for <em>large</em> text edits. */
    private static const int THRESHOLD= 1000;

    /**
     * Text edit visitor that estimates the compound size of an edit tree in characters.
     */
    private static final class SizeVisitor : TextEditVisitor {
        int fSize= 0;

        public bool visit(CopyTargetEdit edit) {
            fSize += edit.getLength();
            return super.visit(edit);
        }

        public bool visit(DeleteEdit edit) {
            fSize += edit.getLength();
            return super.visit(edit);
        }

        public bool visit(InsertEdit edit) {
            fSize += edit.getText().length();
            return super.visit(edit);
        }

        public bool visit(MoveTargetEdit edit) {
            fSize += edit.getLength();
            return super.visit(edit);
        }

        public bool visit(ReplaceEdit edit) {
            fSize += Math.max(edit.getLength(), edit.getText().length());
            return super.visit(edit);
        }
    }

    /**
     * Constructs a new edit processor for the given document.
     *
     * @param document the document to manipulate
     * @param root the root of the text edit tree describing the modifications. By passing a text
     *        edit a a text edit processor the ownership of the edit is transfered to the text edit
     *        processors. Clients must not modify the edit (e.g adding new children) any longer.
     * @param style {@link TextEdit#NONE}, {@link TextEdit#CREATE_UNDO} or
     *        {@link TextEdit#UPDATE_REGIONS})
     */
    public this(IDocument document, TextEdit root, int style) {
        super(document, root, style);
    }

    /*
     * @see org.eclipse.text.edits.TextEditProcessor#performEdits()
     */
    public UndoEdit performEdits()  {
        IDocument document= getDocument();
        if (!( cast(IDocumentExtension4)document ))
            return super.performEdits();

        IDocumentExtension4 extension= cast(IDocumentExtension4) document;
        bool isLargeEdit= isLargeEdit(getRoot());
        DocumentRewriteSessionType type= isLargeEdit ? DocumentRewriteSessionType.UNRESTRICTED : DocumentRewriteSessionType.UNRESTRICTED_SMALL;

        DocumentRewriteSession session= extension.startRewriteSession(type);
        try {
            return super.performEdits();
        } finally {
            extension.stopRewriteSession(session);
        }
    }

    /**
     * Returns <code>true</code> if the passed edit is considered <em>large</em>,
     * <code>false</code> otherwise.
     *
     * @param edit the edit to check
     * @return <code>true</code> if <code>edit</code> is considered <em>large</em>,
     *         <code>false</code> otherwise
     * @since 3.3
     */
    public static bool isLargeEdit(TextEdit edit) {
        SizeVisitor sizeVisitor= new SizeVisitor();
        edit.accept(sizeVisitor);
        return sizeVisitor.fSize > THRESHOLD;
    }

}
