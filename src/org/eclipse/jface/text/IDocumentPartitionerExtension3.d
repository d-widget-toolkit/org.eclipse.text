/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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


module org.eclipse.jface.text.IDocumentPartitionerExtension3;
import org.eclipse.jface.text.IRepairableDocument;
import org.eclipse.jface.text.AbstractDocument;
import org.eclipse.jface.text.ConfigurableLineTracker;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.TypedRegion;
import org.eclipse.jface.text.IDocumentExtension2;
import org.eclipse.jface.text.TypedPosition;
import org.eclipse.jface.text.RewriteSessionEditProcessor;
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
import java.util.Set;


/**
 * Extension interface for {@link org.eclipse.jface.text.IDocumentPartitioner}. Adds the
 * concept of rewrite sessions. A rewrite session is a sequence of replace
 * operations that form a semantic unit.
 *
 * @since 3.1
 */
public interface IDocumentPartitionerExtension3 {

    /**
     * Tells the document partitioner that a rewrite session started. A rewrite
     * session is a sequence of replace operations that form a semantic unit.
     * The document partitioner is allowed to use that information for internal
     * optimization.
     *
     * @param session the rewrite session
     * @throws IllegalStateException in case there is already an active rewrite session
     */
    void startRewriteSession(DocumentRewriteSession session) ;

    /**
     * Tells the document partitioner that the rewrite session has finished.
     * This method is only called when <code>startRewriteSession</code> has
     * been called before.
     *
     * @param session the rewrite session
     */
    void stopRewriteSession(DocumentRewriteSession session);

    /**
     * Returns the active rewrite session of this document or <code>null</code>.
     *
     * @return the active rewrite session or <code>null</code>
     */
    DocumentRewriteSession getActiveRewriteSession();

    /**
     * Connects this partitioner to a document. Connect indicates the begin of
     * the usage of the receiver as partitioner of the given document. Thus,
     * resources the partitioner needs to be operational for this document
     * should be allocated.
     * <p>
     * The caller of this method must ensure that this partitioner is also set
     * as the document's document partitioner.
     * <p>
     * <code>delayInitialization</code> indicates whether the partitioner is
     * allowed to delay it initial computation of the document's partitioning
     * until it has to answer the first query.
     *
     * Replaces {@link IDocumentPartitioner#connect(IDocument)}.
     *
     * @param document the document to be connected to
     * @param delayInitialization <code>true</code> if initialization can be delayed, <code>false</code> otherwise
     */
    void connect(IDocument document, bool delayInitialization);
}
