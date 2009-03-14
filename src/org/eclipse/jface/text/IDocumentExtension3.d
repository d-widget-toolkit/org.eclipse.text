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
module org.eclipse.jface.text.IDocumentExtension3;

import org.eclipse.jface.text.IDocumentPartitioningListener; // packageimport
import org.eclipse.jface.text.DefaultTextHover; // packageimport
import org.eclipse.jface.text.AbstractInformationControl; // packageimport
import org.eclipse.jface.text.TextUtilities; // packageimport
import org.eclipse.jface.text.IInformationControlCreatorExtension; // packageimport
import org.eclipse.jface.text.AbstractInformationControlManager; // packageimport
import org.eclipse.jface.text.ITextViewerExtension2; // packageimport
import org.eclipse.jface.text.IDocumentPartitioner; // packageimport
import org.eclipse.jface.text.DefaultIndentLineAutoEditStrategy; // packageimport
import org.eclipse.jface.text.ITextSelection; // packageimport
import org.eclipse.jface.text.Document; // packageimport
import org.eclipse.jface.text.FindReplaceDocumentAdapterContentProposalProvider; // packageimport
import org.eclipse.jface.text.ITextListener; // packageimport
import org.eclipse.jface.text.BadPartitioningException; // packageimport
import org.eclipse.jface.text.ITextViewerExtension5; // packageimport
import org.eclipse.jface.text.IDocumentPartitionerExtension3; // packageimport
import org.eclipse.jface.text.IUndoManager; // packageimport
import org.eclipse.jface.text.ITextHoverExtension2; // packageimport
import org.eclipse.jface.text.IRepairableDocument; // packageimport
import org.eclipse.jface.text.IRewriteTarget; // packageimport
import org.eclipse.jface.text.DefaultPositionUpdater; // packageimport
import org.eclipse.jface.text.RewriteSessionEditProcessor; // packageimport
import org.eclipse.jface.text.TextViewerHoverManager; // packageimport
import org.eclipse.jface.text.DocumentRewriteSession; // packageimport
import org.eclipse.jface.text.TextViewer; // packageimport
import org.eclipse.jface.text.ITextViewerExtension8; // packageimport
import org.eclipse.jface.text.RegExMessages; // packageimport
import org.eclipse.jface.text.IDelayedInputChangeProvider; // packageimport
import org.eclipse.jface.text.ITextOperationTargetExtension; // packageimport
import org.eclipse.jface.text.IWidgetTokenOwner; // packageimport
import org.eclipse.jface.text.IViewportListener; // packageimport
import org.eclipse.jface.text.GapTextStore; // packageimport
import org.eclipse.jface.text.MarkSelection; // packageimport
import org.eclipse.jface.text.IDocumentPartitioningListenerExtension; // packageimport
import org.eclipse.jface.text.IDocumentAdapterExtension; // packageimport
import org.eclipse.jface.text.IInformationControlExtension; // packageimport
import org.eclipse.jface.text.IDocumentPartitioningListenerExtension2; // packageimport
import org.eclipse.jface.text.DefaultDocumentAdapter; // packageimport
import org.eclipse.jface.text.ITextViewerExtension3; // packageimport
import org.eclipse.jface.text.IInformationControlCreator; // packageimport
import org.eclipse.jface.text.TypedRegion; // packageimport
import org.eclipse.jface.text.ISynchronizable; // packageimport
import org.eclipse.jface.text.IMarkRegionTarget; // packageimport
import org.eclipse.jface.text.TextViewerUndoManager; // packageimport
import org.eclipse.jface.text.IRegion; // packageimport
import org.eclipse.jface.text.IInformationControlExtension2; // packageimport
import org.eclipse.jface.text.IDocumentExtension4; // packageimport
import org.eclipse.jface.text.IDocumentExtension2; // packageimport
import org.eclipse.jface.text.IDocumentPartitionerExtension2; // packageimport
import org.eclipse.jface.text.Assert; // packageimport
import org.eclipse.jface.text.DefaultInformationControl; // packageimport
import org.eclipse.jface.text.IWidgetTokenOwnerExtension; // packageimport
import org.eclipse.jface.text.DocumentClone; // packageimport
import org.eclipse.jface.text.DefaultUndoManager; // packageimport
import org.eclipse.jface.text.IFindReplaceTarget; // packageimport
import org.eclipse.jface.text.IAutoEditStrategy; // packageimport
import org.eclipse.jface.text.ILineTrackerExtension; // packageimport
import org.eclipse.jface.text.IUndoManagerExtension; // packageimport
import org.eclipse.jface.text.TextSelection; // packageimport
import org.eclipse.jface.text.DefaultAutoIndentStrategy; // packageimport
import org.eclipse.jface.text.IAutoIndentStrategy; // packageimport
import org.eclipse.jface.text.IPainter; // packageimport
import org.eclipse.jface.text.IInformationControl; // packageimport
import org.eclipse.jface.text.IInformationControlExtension3; // packageimport
import org.eclipse.jface.text.ITextViewerExtension6; // packageimport
import org.eclipse.jface.text.IInformationControlExtension4; // packageimport
import org.eclipse.jface.text.DefaultLineTracker; // packageimport
import org.eclipse.jface.text.IDocumentInformationMappingExtension; // packageimport
import org.eclipse.jface.text.IRepairableDocumentExtension; // packageimport
import org.eclipse.jface.text.ITextHover; // packageimport
import org.eclipse.jface.text.FindReplaceDocumentAdapter; // packageimport
import org.eclipse.jface.text.ILineTracker; // packageimport
import org.eclipse.jface.text.Line; // packageimport
import org.eclipse.jface.text.ITextViewerExtension; // packageimport
import org.eclipse.jface.text.IDocumentAdapter; // packageimport
import org.eclipse.jface.text.TextEvent; // packageimport
import org.eclipse.jface.text.BadLocationException; // packageimport
import org.eclipse.jface.text.AbstractDocument; // packageimport
import org.eclipse.jface.text.AbstractLineTracker; // packageimport
import org.eclipse.jface.text.TreeLineTracker; // packageimport
import org.eclipse.jface.text.ITextPresentationListener; // packageimport
import org.eclipse.jface.text.Region; // packageimport
import org.eclipse.jface.text.ITextViewer; // packageimport
import org.eclipse.jface.text.IDocumentInformationMapping; // packageimport
import org.eclipse.jface.text.MarginPainter; // packageimport
import org.eclipse.jface.text.IPaintPositionManager; // packageimport
import org.eclipse.jface.text.TextPresentation; // packageimport
import org.eclipse.jface.text.IFindReplaceTargetExtension; // packageimport
import org.eclipse.jface.text.ISlaveDocumentManagerExtension; // packageimport
import org.eclipse.jface.text.ISelectionValidator; // packageimport
import org.eclipse.jface.text.IDocumentExtension; // packageimport
import org.eclipse.jface.text.PropagatingFontFieldEditor; // packageimport
import org.eclipse.jface.text.ConfigurableLineTracker; // packageimport
import org.eclipse.jface.text.SlaveDocumentEvent; // packageimport
import org.eclipse.jface.text.IDocumentListener; // packageimport
import org.eclipse.jface.text.PaintManager; // packageimport
import org.eclipse.jface.text.IFindReplaceTargetExtension3; // packageimport
import org.eclipse.jface.text.ITextDoubleClickStrategy; // packageimport
import org.eclipse.jface.text.Position; // packageimport
import org.eclipse.jface.text.TextMessages; // packageimport
import org.eclipse.jface.text.CopyOnWriteTextStore; // packageimport
import org.eclipse.jface.text.WhitespaceCharacterPainter; // packageimport
import org.eclipse.jface.text.IPositionUpdater; // packageimport
import org.eclipse.jface.text.DefaultTextDoubleClickStrategy; // packageimport
import org.eclipse.jface.text.ListLineTracker; // packageimport
import org.eclipse.jface.text.ITextInputListener; // packageimport
import org.eclipse.jface.text.BadPositionCategoryException; // packageimport
import org.eclipse.jface.text.IWidgetTokenKeeperExtension; // packageimport
import org.eclipse.jface.text.IInputChangedListener; // packageimport
import org.eclipse.jface.text.ITextOperationTarget; // packageimport
import org.eclipse.jface.text.IDocumentInformationMappingExtension2; // packageimport
import org.eclipse.jface.text.ITextViewerExtension7; // packageimport
import org.eclipse.jface.text.IInformationControlExtension5; // packageimport
import org.eclipse.jface.text.IDocumentRewriteSessionListener; // packageimport
import org.eclipse.jface.text.JFaceTextUtil; // packageimport
import org.eclipse.jface.text.AbstractReusableInformationControlCreator; // packageimport
import org.eclipse.jface.text.TabsToSpacesConverter; // packageimport
import org.eclipse.jface.text.CursorLinePainter; // packageimport
import org.eclipse.jface.text.ITextHoverExtension; // packageimport
import org.eclipse.jface.text.IEventConsumer; // packageimport
import org.eclipse.jface.text.IDocument; // packageimport
import org.eclipse.jface.text.IWidgetTokenKeeper; // packageimport
import org.eclipse.jface.text.DocumentCommand; // packageimport
import org.eclipse.jface.text.TypedPosition; // packageimport
import org.eclipse.jface.text.IEditingSupportRegistry; // packageimport
import org.eclipse.jface.text.IDocumentPartitionerExtension; // packageimport
import org.eclipse.jface.text.AbstractHoverInformationControlManager; // packageimport
import org.eclipse.jface.text.IEditingSupport; // packageimport
import org.eclipse.jface.text.IMarkSelection; // packageimport
import org.eclipse.jface.text.ISlaveDocumentManager; // packageimport
import org.eclipse.jface.text.DocumentEvent; // packageimport
import org.eclipse.jface.text.DocumentPartitioningChangedEvent; // packageimport
import org.eclipse.jface.text.ITextStore; // packageimport
import org.eclipse.jface.text.JFaceTextMessages; // packageimport
import org.eclipse.jface.text.DocumentRewriteSessionEvent; // packageimport
import org.eclipse.jface.text.SequentialRewriteTextStore; // packageimport
import org.eclipse.jface.text.DocumentRewriteSessionType; // packageimport
import org.eclipse.jface.text.TextAttribute; // packageimport
import org.eclipse.jface.text.ITextViewerExtension4; // packageimport
import org.eclipse.jface.text.ITypedRegion; // packageimport


import java.lang.all;
import java.util.Set;

/**
 * Extension interface for {@link org.eclipse.jface.text.IDocument}.
 * <p>
 * Adds the concept of multiple partitionings and the concept of zero-length
 * partitions in conjunction with open and delimited partitions. A delimited
 * partition has a well defined start delimiter and a well defined end
 * delimiter. Between two delimited partitions there may be an open partition of
 * length zero.
 * <p>
 *
 * In order to fulfill the contract of this interface, the document must be
 * configured with a document partitioner implementing
 * {@link org.eclipse.jface.text.IDocumentPartitionerExtension2}.
 *
 * @see org.eclipse.jface.text.IDocumentPartitionerExtension2
 * @since 3.0
 */
public interface IDocumentExtension3 {

    /**
     * The identifier of the default partitioning.
     */
    final static String DEFAULT_PARTITIONING= "__dftl_partitioning"; //$NON-NLS-1$


    /**
     * Returns the existing partitionings for this document. This includes
     * the default partitioning.
     *
     * @return the existing partitionings for this document
     */
    String[] getPartitionings();

    /**
     * Returns the set of legal content types of document partitions for the given partitioning
     * This set can be empty. The set can contain more content types than  contained by the
     * result of <code>getPartitioning(partitioning, 0, getLength())</code>.
     *
     * @param partitioning the partitioning for which to return the legal content types
     * @return the set of legal content types
     * @exception BadPartitioningException if partitioning is invalid for this document
     */
    String[] getLegalContentTypes(String partitioning) ;


    /**
     * Returns the type of the document partition containing the given offset
     * for the given partitioning. This is a convenience method for
     * <code>getPartition(partitioning, offset, bool).getType()</code>.
     * <p>
     * If <code>preferOpenPartitions</code> is <code>true</code>,
     * precedence is given to an open partition ending at <code>offset</code>
     * over a delimited partition starting at <code>offset</code>. If it is
     * <code>false</code>, precedence is given to the partition that does not
     * end at <code>offset</code>.
     * </p>
     * This is only supported if the connected <code>IDocumentPartitioner</code>
     * supports it, i.e. implements <code>IDocumentPartitionerExtension2</code>.
     * Otherwise, <code>preferOpenPartitions</code> is ignored.
     * </p>
     *
     * @param partitioning the partitioning
     * @param offset the document offset
     * @param preferOpenPartitions <code>true</code> if precedence should be
     *        given to a open partition ending at <code>offset</code> over a
     *        closed partition starting at <code>offset</code>
     * @return the partition type
     * @exception BadLocationException if offset is invalid in this document
     * @exception BadPartitioningException if partitioning is invalid for this document
     */
    String getContentType(String partitioning, int offset, bool preferOpenPartitions);

    /**
     * Returns the document partition of the given partitioning in which the
     * given offset is located.
     * <p>
     * If <code>preferOpenPartitions</code> is <code>true</code>,
     * precedence is given to an open partition ending at <code>offset</code>
     * over a delimited partition starting at <code>offset</code>. If it is
     * <code>false</code>, precedence is given to the partition that does not
     * end at <code>offset</code>.
     * </p>
     * This is only supported if the connected <code>IDocumentPartitioner</code>
     * supports it, i.e. implements <code>IDocumentPartitionerExtension2</code>.
     * Otherwise, <code>preferOpenPartitions</code> is ignored.
     * </p>
     *
     * @param partitioning the partitioning
     * @param offset the document offset
     * @param preferOpenPartitions <code>true</code> if precedence should be
     *        given to a open partition ending at <code>offset</code> over a
     *        closed partition starting at <code>offset</code>
     * @return a specification of the partition
     * @exception BadLocationException if offset is invalid in this document
     * @exception BadPartitioningException if partitioning is invalid for this document
     */
    ITypedRegion getPartition(String partitioning, int offset, bool preferOpenPartitions);

    /**
     * Computes the partitioning of the given document range based on the given
     * partitioning type.
     * <p>
     * If <code>includeZeroLengthPartitions</code> is <code>true</code>, a
     * zero-length partition of an open partition type (usually the default
     * partition) is included between two closed partitions. If it is
     * <code>false</code>, no zero-length partitions are included.
     * </p>
     * This is only supported if the connected <code>IDocumentPartitioner</code>
     * supports it, i.e. implements <code>IDocumentPartitionerExtension2</code>.
     * Otherwise, <code>includeZeroLengthPartitions</code> is ignored.
     * </p>
     *
     * @param partitioning the document's partitioning type
     * @param offset the document offset at which the range starts
     * @param length the length of the document range
     * @param includeZeroLengthPartitions <code>true</code> if zero-length
     *        partitions should be returned as part of the computed partitioning
     * @return a specification of the range's partitioning
     * @exception BadLocationException if the range is invalid in this document$
     * @exception BadPartitioningException if partitioning is invalid for this document
     */
    ITypedRegion[] computePartitioning(String partitioning, int offset, int length, bool includeZeroLengthPartitions);

    /**
     * Sets this document's partitioner. The caller of this method is responsible for
     * disconnecting the document's old partitioner from the document and to
     * connect the new partitioner to the document. Informs all document partitioning
     * listeners about this change.
     *
     * @param  partitioning the partitioning for which to set the partitioner
     * @param partitioner the document's new partitioner
     * @see IDocumentPartitioningListener
     */
    void setDocumentPartitioner(String partitioning, IDocumentPartitioner partitioner);

    /**
     * Returns the partitioner for the given partitioning or <code>null</code> if
     * no partitioner is registered.
     *
     * @param  partitioning the partitioning for which to set the partitioner
     * @return the partitioner for the given partitioning
     */
    IDocumentPartitioner getDocumentPartitioner(String partitioning);
}
