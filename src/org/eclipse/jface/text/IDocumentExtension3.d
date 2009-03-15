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
