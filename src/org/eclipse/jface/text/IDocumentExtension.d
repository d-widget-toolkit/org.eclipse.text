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


module org.eclipse.jface.text.IDocumentExtension;
import org.eclipse.jface.text.IRepairableDocument;
import org.eclipse.jface.text.AbstractDocument;
import org.eclipse.jface.text.IDocumentPartitionerExtension3;
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
import org.eclipse.jface.text.IDocumentRewriteSessionListener;
import org.eclipse.jface.text.IDocumentInformationMapping;
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
 * Extension interface for {@link org.eclipse.jface.text.IDocument}.<p>
 *
 * It introduces the notion of sequentially rewriting a document. This is to tell a
 * document that a sequence of non-overlapping replace operation is about to be
 * performed. Implementers can use this knowledge for internal optimization.<p>
 *
 * Is also introduces the concept of post notification replaces. This is, a document
 * listener who is informed about a document change can cause a derived document
 * change. As the listener is not allowed to directly modify the document, it can
 * register a replace operation that is performed directly after all document listeners
 * have been notified.
 *
 * @since 2.0
 */
public interface IDocumentExtension {

    /**
     * Interface for a post notification replace operation.
     */
    public interface IReplace {

        /**
         * Executes the replace operation on the given document.
         *
         * @param document the document to be changed
         * @param owner the owner of this replace operation
         */
        void perform(IDocument document, IDocumentListener owner);
    }

    /**
     * Callback for document listeners to be used inside <code>documentChanged</code>
     * to register a post notification replace operation on the document notifying them.
     *
     * @param owner the owner of the replace operation
     * @param replace the replace operation to be executed
     * @exception UnsupportedOperationException if <code>registerPostNotificationReplace</code>
     *  is not supported by this document
     */
    void registerPostNotificationReplace(IDocumentListener owner, IReplace replace) ;

    /**
     * Stops the processing of registered post notification replace operations until
     * <code>resumePostNotificationProcessing</code> is called.
     */
    void stopPostNotificationProcessing();

    /**
     * Resumes the processing of post notification replace operations. If the queue of registered
     * <code>IDocumentExtension.IReplace</code> objects is not empty, they are immediately processed if the
     * document is not inside a replace operation. If the document is inside a replace operation,
     * they are processed directly after the replace operation has finished.
     */
    void resumePostNotificationProcessing();

    /**
     * Tells the document that it is about to be sequentially rewritten. That is a
     * sequence of non-overlapping replace operations will be performed on it. The
     * <code>normalize</code> flag indicates whether the rewrite is performed from
     * the start of the document to its end or from an arbitrary start offset. <p>
     *
     * The document is considered being in sequential rewrite mode as long as
     * <code>stopSequentialRewrite</code> has not been called.
     *
     * @param normalize <code>true</code> if performed from the start to the end of the document
     * @deprecated since 3.1. Use {@link IDocumentExtension4#startRewriteSession(DocumentRewriteSessionType)} instead.
     */
    void startSequentialRewrite(bool normalize);

    /**
     * Tells the document that the sequential rewrite has been finished. This method
     * has only any effect if <code>startSequentialRewrite</code> has been called before.
     * @deprecated since 3.1. Use {@link IDocumentExtension4#stopRewriteSession(DocumentRewriteSession)} instead.
     */
    void stopSequentialRewrite();
}
