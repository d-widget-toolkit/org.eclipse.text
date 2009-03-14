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
module org.eclipse.jface.text.IDocumentPartitioner;

// import org.eclipse.jface.text.IDocumentPartitioningListener; // packageimport
// import org.eclipse.jface.text.DefaultTextHover; // packageimport
// import org.eclipse.jface.text.AbstractInformationControl; // packageimport
// import org.eclipse.jface.text.TextUtilities; // packageimport
// import org.eclipse.jface.text.IInformationControlCreatorExtension; // packageimport
// import org.eclipse.jface.text.AbstractInformationControlManager; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension2; // packageimport
// import org.eclipse.jface.text.DefaultIndentLineAutoEditStrategy; // packageimport
// import org.eclipse.jface.text.ITextSelection; // packageimport
// import org.eclipse.jface.text.Document; // packageimport
// import org.eclipse.jface.text.FindReplaceDocumentAdapterContentProposalProvider; // packageimport
// import org.eclipse.jface.text.ITextListener; // packageimport
// import org.eclipse.jface.text.BadPartitioningException; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension5; // packageimport
// import org.eclipse.jface.text.IDocumentPartitionerExtension3; // packageimport
// import org.eclipse.jface.text.IUndoManager; // packageimport
// import org.eclipse.jface.text.ITextHoverExtension2; // packageimport
// import org.eclipse.jface.text.IRepairableDocument; // packageimport
// import org.eclipse.jface.text.IRewriteTarget; // packageimport
// import org.eclipse.jface.text.DefaultPositionUpdater; // packageimport
// import org.eclipse.jface.text.RewriteSessionEditProcessor; // packageimport
// import org.eclipse.jface.text.TextViewerHoverManager; // packageimport
// import org.eclipse.jface.text.DocumentRewriteSession; // packageimport
// import org.eclipse.jface.text.TextViewer; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension8; // packageimport
// import org.eclipse.jface.text.RegExMessages; // packageimport
// import org.eclipse.jface.text.IDelayedInputChangeProvider; // packageimport
// import org.eclipse.jface.text.ITextOperationTargetExtension; // packageimport
// import org.eclipse.jface.text.IWidgetTokenOwner; // packageimport
// import org.eclipse.jface.text.IViewportListener; // packageimport
// import org.eclipse.jface.text.GapTextStore; // packageimport
// import org.eclipse.jface.text.MarkSelection; // packageimport
// import org.eclipse.jface.text.IDocumentPartitioningListenerExtension; // packageimport
// import org.eclipse.jface.text.IDocumentAdapterExtension; // packageimport
// import org.eclipse.jface.text.IInformationControlExtension; // packageimport
// import org.eclipse.jface.text.IDocumentPartitioningListenerExtension2; // packageimport
// import org.eclipse.jface.text.DefaultDocumentAdapter; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension3; // packageimport
// import org.eclipse.jface.text.IInformationControlCreator; // packageimport
// import org.eclipse.jface.text.TypedRegion; // packageimport
// import org.eclipse.jface.text.ISynchronizable; // packageimport
// import org.eclipse.jface.text.IMarkRegionTarget; // packageimport
// import org.eclipse.jface.text.TextViewerUndoManager; // packageimport
// import org.eclipse.jface.text.IRegion; // packageimport
// import org.eclipse.jface.text.IInformationControlExtension2; // packageimport
// import org.eclipse.jface.text.IDocumentExtension4; // packageimport
// import org.eclipse.jface.text.IDocumentExtension2; // packageimport
// import org.eclipse.jface.text.IDocumentPartitionerExtension2; // packageimport
// import org.eclipse.jface.text.Assert; // packageimport
// import org.eclipse.jface.text.DefaultInformationControl; // packageimport
// import org.eclipse.jface.text.IWidgetTokenOwnerExtension; // packageimport
// import org.eclipse.jface.text.DocumentClone; // packageimport
// import org.eclipse.jface.text.DefaultUndoManager; // packageimport
// import org.eclipse.jface.text.IFindReplaceTarget; // packageimport
// import org.eclipse.jface.text.IAutoEditStrategy; // packageimport
// import org.eclipse.jface.text.ILineTrackerExtension; // packageimport
// import org.eclipse.jface.text.IUndoManagerExtension; // packageimport
// import org.eclipse.jface.text.TextSelection; // packageimport
// import org.eclipse.jface.text.DefaultAutoIndentStrategy; // packageimport
// import org.eclipse.jface.text.IAutoIndentStrategy; // packageimport
// import org.eclipse.jface.text.IPainter; // packageimport
// import org.eclipse.jface.text.IInformationControl; // packageimport
// import org.eclipse.jface.text.IInformationControlExtension3; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension6; // packageimport
// import org.eclipse.jface.text.IInformationControlExtension4; // packageimport
// import org.eclipse.jface.text.DefaultLineTracker; // packageimport
// import org.eclipse.jface.text.IDocumentInformationMappingExtension; // packageimport
// import org.eclipse.jface.text.IRepairableDocumentExtension; // packageimport
// import org.eclipse.jface.text.ITextHover; // packageimport
// import org.eclipse.jface.text.FindReplaceDocumentAdapter; // packageimport
// import org.eclipse.jface.text.ILineTracker; // packageimport
// import org.eclipse.jface.text.Line; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension; // packageimport
// import org.eclipse.jface.text.IDocumentAdapter; // packageimport
// import org.eclipse.jface.text.TextEvent; // packageimport
// import org.eclipse.jface.text.BadLocationException; // packageimport
// import org.eclipse.jface.text.AbstractDocument; // packageimport
// import org.eclipse.jface.text.AbstractLineTracker; // packageimport
// import org.eclipse.jface.text.TreeLineTracker; // packageimport
// import org.eclipse.jface.text.ITextPresentationListener; // packageimport
// import org.eclipse.jface.text.Region; // packageimport
// import org.eclipse.jface.text.ITextViewer; // packageimport
// import org.eclipse.jface.text.IDocumentInformationMapping; // packageimport
// import org.eclipse.jface.text.MarginPainter; // packageimport
// import org.eclipse.jface.text.IPaintPositionManager; // packageimport
// import org.eclipse.jface.text.TextPresentation; // packageimport
// import org.eclipse.jface.text.IFindReplaceTargetExtension; // packageimport
// import org.eclipse.jface.text.ISlaveDocumentManagerExtension; // packageimport
// import org.eclipse.jface.text.ISelectionValidator; // packageimport
// import org.eclipse.jface.text.IDocumentExtension; // packageimport
// import org.eclipse.jface.text.PropagatingFontFieldEditor; // packageimport
// import org.eclipse.jface.text.ConfigurableLineTracker; // packageimport
// import org.eclipse.jface.text.SlaveDocumentEvent; // packageimport
// import org.eclipse.jface.text.IDocumentListener; // packageimport
// import org.eclipse.jface.text.PaintManager; // packageimport
// import org.eclipse.jface.text.IFindReplaceTargetExtension3; // packageimport
// import org.eclipse.jface.text.ITextDoubleClickStrategy; // packageimport
// import org.eclipse.jface.text.IDocumentExtension3; // packageimport
// import org.eclipse.jface.text.Position; // packageimport
// import org.eclipse.jface.text.TextMessages; // packageimport
// import org.eclipse.jface.text.CopyOnWriteTextStore; // packageimport
// import org.eclipse.jface.text.WhitespaceCharacterPainter; // packageimport
// import org.eclipse.jface.text.IPositionUpdater; // packageimport
// import org.eclipse.jface.text.DefaultTextDoubleClickStrategy; // packageimport
// import org.eclipse.jface.text.ListLineTracker; // packageimport
// import org.eclipse.jface.text.ITextInputListener; // packageimport
// import org.eclipse.jface.text.BadPositionCategoryException; // packageimport
// import org.eclipse.jface.text.IWidgetTokenKeeperExtension; // packageimport
// import org.eclipse.jface.text.IInputChangedListener; // packageimport
// import org.eclipse.jface.text.ITextOperationTarget; // packageimport
// import org.eclipse.jface.text.IDocumentInformationMappingExtension2; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension7; // packageimport
// import org.eclipse.jface.text.IInformationControlExtension5; // packageimport
// import org.eclipse.jface.text.IDocumentRewriteSessionListener; // packageimport
// import org.eclipse.jface.text.JFaceTextUtil; // packageimport
// import org.eclipse.jface.text.AbstractReusableInformationControlCreator; // packageimport
// import org.eclipse.jface.text.TabsToSpacesConverter; // packageimport
// import org.eclipse.jface.text.CursorLinePainter; // packageimport
// import org.eclipse.jface.text.ITextHoverExtension; // packageimport
// import org.eclipse.jface.text.IEventConsumer; // packageimport
import org.eclipse.jface.text.IDocument; // packageimport
// import org.eclipse.jface.text.IWidgetTokenKeeper; // packageimport
// import org.eclipse.jface.text.DocumentCommand; // packageimport
// import org.eclipse.jface.text.TypedPosition; // packageimport
// import org.eclipse.jface.text.IEditingSupportRegistry; // packageimport
// import org.eclipse.jface.text.IDocumentPartitionerExtension; // packageimport
// import org.eclipse.jface.text.AbstractHoverInformationControlManager; // packageimport
// import org.eclipse.jface.text.IEditingSupport; // packageimport
// import org.eclipse.jface.text.IMarkSelection; // packageimport
// import org.eclipse.jface.text.ISlaveDocumentManager; // packageimport
import org.eclipse.jface.text.DocumentEvent; // packageimport
// import org.eclipse.jface.text.DocumentPartitioningChangedEvent; // packageimport
// import org.eclipse.jface.text.ITextStore; // packageimport
// import org.eclipse.jface.text.JFaceTextMessages; // packageimport
// import org.eclipse.jface.text.DocumentRewriteSessionEvent; // packageimport
// import org.eclipse.jface.text.SequentialRewriteTextStore; // packageimport
// import org.eclipse.jface.text.DocumentRewriteSessionType; // packageimport
// import org.eclipse.jface.text.TextAttribute; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension4; // packageimport
import org.eclipse.jface.text.ITypedRegion; // packageimport


import java.lang.all;
import java.util.Set;



/**
 * A document partitioner divides a document into a set
 * of disjoint text partitions. Each partition has a content type, an
 * offset, and a length. The document partitioner is connected to one document
 * and informed about all changes of this document before any of the
 * document's document listeners. A document partitioner can thus
 * incrementally update on the receipt of a document change event.<p>
 *
 * In order to provided backward compatibility for clients of <code>IDocumentPartitioner</code>, extension
 * interfaces are used to provide a means of evolution. The following extension interfaces
 * exist:
 * <ul>
 * <li> {@link org.eclipse.jface.text.IDocumentPartitionerExtension} since version 2.0 replacing
 *      the <code>documentChanged</code> method with a new one returning the minimal document region
 *      comprising all partition changes.</li>
 * <li> {@link org.eclipse.jface.text.IDocumentPartitionerExtension2} since version 3.0
 *      introducing zero-length partitions in conjunction with the distinction between
 *      open and closed partitions. Also provides inside in the implementation of the partitioner
 *      by exposing the position category used for managing the partitioning information.</li>
 * <li> {@link org.eclipse.jface.text.IDocumentPartitionerExtension3} since version 3.1 introducing
 *      rewrite session. It also replaces the existing {@link #connect(IDocument)} method with
 *      a new one: {@link org.eclipse.jface.text.IDocumentPartitionerExtension3#connect(IDocument, bool)}.
 * </ul>
 * <p>
 * Clients may implement this interface and its extension interfaces or use the standard
 * implementation <code>DefaultPartitioner</code>.
 * </p>
 *
 * @see org.eclipse.jface.text.IDocumentPartitionerExtension
 * @see org.eclipse.jface.text.IDocumentPartitionerExtension2
 * @see org.eclipse.jface.text.IDocument
 */
public interface IDocumentPartitioner {

    /**
     * Connects the partitioner to a document.
     * Connect indicates the begin of the usage of the receiver
     * as partitioner of the given document. Thus, resources the partitioner
     * needs to be operational for this document should be allocated.<p>
     *
     * The caller of this method must ensure that this partitioner is
     * also set as the document's document partitioner.<p>
     *
     * This method has been replaced with {@link IDocumentPartitionerExtension3#connect(IDocument, bool)}.
     * Implementers should default a call <code>connect(document)</code> to
     * <code>connect(document, false)</code> in order to sustain the same semantics.
     *
     * @param document the document to be connected to
     */
    void connect(IDocument document);

    /**
     * Disconnects the partitioner from the document it is connected to.
     * Disconnect indicates the end of the usage of the receiver as
     * partitioner of the connected document. Thus, resources the partitioner
     * needed to be operation for its connected document should be deallocated.<p>
     * The caller of this method should also must ensure that this partitioner is
     * no longer the document's partitioner.
     */
    void disconnect();

    /**
     * Informs about a forthcoming document change. Will be called by the
     * connected document and is not intended to be used by clients
     * other than the connected document.
     *
     * @param event the event describing the forthcoming change
     */
    void documentAboutToBeChanged(DocumentEvent event);

    /**
     * The document has been changed. The partitioner updates
     * the document's partitioning and returns whether the structure of the
     * document partitioning has been changed, i.e. whether partitions
     * have been added or removed. Will be called by the connected document and
     * is not intended to be used by clients other than the connected document.<p>
     *
     * This method has been replaced by {@link IDocumentPartitionerExtension#documentChanged2(DocumentEvent)}.
     *
     * @param event the event describing the document change
     * @return <code>true</code> if partitioning changed
     */
    bool documentChanged(DocumentEvent event);

    /**
     * Returns the set of all legal content types of this partitioner.
     * I.e. any result delivered by this partitioner may not contain a content type
     * which would not be included in this method's result.
     *
     * @return the set of legal content types
     */
    String[] getLegalContentTypes();

    /**
     * Returns the content type of the partition containing the
     * given offset in the connected document. There must be a
     * document connected to this partitioner.<p>
     *
     * Use {@link IDocumentPartitionerExtension2#getContentType(int, bool)} when
     * zero-length partitions are supported. In that case this method is
     * equivalent:
     * <pre>
     *    IDocumentPartitionerExtension2 extension= cast(IDocumentPartitionerExtension2) partitioner;
     *    return extension.getContentType(offset, false);
     * </pre>
     *
     * @param offset the offset in the connected document
     * @return the content type of the offset's partition
     */
    String getContentType(int offset);

    /**
     * Returns the partitioning of the given range of the connected
     * document. There must be a document connected to this partitioner.<p>
     *
     * Use {@link IDocumentPartitionerExtension2#computePartitioning(int, int, bool)} when
     * zero-length partitions are supported. In that case this method is
     * equivalent:
     * <pre>
     *    IDocumentPartitionerExtension2 extension= cast(IDocumentPartitionerExtension2) partitioner;
     *    return extension.computePartitioning(offset, length, false);
     * </pre>
     *
     * @param offset the offset of the range of interest
     * @param length the length of the range of interest
     * @return the partitioning of the range
     */
    ITypedRegion[] computePartitioning(int offset, int length);

    /**
     * Returns the partition containing the given offset of
     * the connected document. There must be a document connected to this
     * partitioner.<p>
     *
     * Use {@link IDocumentPartitionerExtension2#getPartition(int, bool)} when
     * zero-length partitions are supported. In that case this method is
     * equivalent:
     * <pre>
     *    IDocumentPartitionerExtension2 extension= cast(IDocumentPartitionerExtension2) partitioner;
     *    return extension.getPartition(offset, false);
     * </pre>
     *
     * @param offset the offset for which to determine the partition
     * @return the partition containing the offset
     */
    ITypedRegion getPartition(int offset);
}
