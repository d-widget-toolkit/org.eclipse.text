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


module org.eclipse.jface.text.IDocumentPartitionerExtension2;
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
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.TreeLineTracker;


import java.lang.all;
import java.util.Set;


/**
 * Extension interface for {@link org.eclipse.jface.text.IDocumentPartitioner}.
 * <p>
 * Extends the original concept of a document partitioner to answer the position
 * categories that are used to manage the partitioning information.
 * <p>
 * This extension also introduces the concept of open and delimited partitions.
 * A delimited partition has a predefined textual token delimiting its start and
 * end, while an open partition can fill any space between two delimited
 * partitions.
 * </p>
 * <p>
 * An open partition of length zero can occur between two delimited partitions,
 * thus having the same offset as the following delimited partition. The
 * document start and end are considered to be delimiters of open partitions,
 * i.e. there may be a zero-length partition between the document start and a
 * delimited partition starting at offset 0.
 * </p>
 *
 * @since 3.0
 */
public interface IDocumentPartitionerExtension2 {

    /**
     * Returns the position categories that this partitioners uses in order to manage
     * the partitioning information of the documents. Returns <code>null</code> if
     * no position category is used.
     *
     * @return the position categories used to manage partitioning information or <code>null</code>
     */
    String[] getManagingPositionCategories();


    /* zero-length partition support */

    /**
     * Returns the content type of the partition containing the given offset in
     * the connected document. There must be a document connected to this
     * partitioner.
     * <p>
     * If <code>preferOpenPartitions</code> is <code>true</code>,
     * precedence is given to an open partition ending at <code>offset</code>
     * over a delimited partition starting at <code>offset</code>.
     * <p>
     * This method replaces {@link IDocumentPartitioner#getContentType(int)}and
     * behaves like it when <code>prepreferOpenPartitions</code> is
     * <code>false</code>, i.e. precedence is always given to the partition
     * that does not end at <code>offset</code>.
     * </p>
     *
     * @param offset the offset in the connected document
     * @param preferOpenPartitions <code>true</code> if precedence should be
     *            given to a open partition ending at <code>offset</code> over
     *            a delimited partition starting at <code>offset</code>
     * @return the content type of the offset's partition
     */
    String getContentType(int offset, bool preferOpenPartitions);

    /**
     * Returns the partition containing the given offset of the connected
     * document. There must be a document connected to this partitioner.
     * <p>
     * If <code>preferOpenPartitions</code> is <code>true</code>,
     * precedence is given to an open partition ending at <code>offset</code>
     * over a delimited partition starting at <code>offset</code>.
     * <p>
     * This method replaces {@link IDocumentPartitioner#getPartition(int)}and
     * behaves like it when <preferOpenPartitions</code> is <code>false
     * </code>, i.e. precedence is always given to the partition that does not
     * end at <code>offset</code>.
     * </p>
     *
     * @param offset the offset for which to determine the partition
     * @param preferOpenPartitions <code>true</code> if precedence should be
     *            given to a open partition ending at <code>offset</code> over
     *            a delimited partition starting at <code>offset</code>
     * @return the partition containing the offset
     */
    ITypedRegion getPartition(int offset, bool preferOpenPartitions);

    /**
     * Returns the partitioning of the given range of the connected document.
     * There must be a document connected to this partitioner.
     * <p>
     * If <code>includeZeroLengthPartitions</code> is <code>true</code>, a
     * zero-length partition of an open partition type (usually the default
     * partition) is included between two delimited partitions. If it is
     * <code>false</code>, no zero-length partitions are included.
     * </p>
     * <p>
     * This method replaces
     * {@link IDocumentPartitioner#computePartitioning(int, int)}and behaves
     * like it when <code>includeZeroLengthPartitions</code> is
     * <code>false</code>.
     * </p>
     *
     * @param offset the offset of the range of interest
     * @param length the length of the range of interest
     * @param includeZeroLengthPartitions <code>true</code> if zero-length
     *            partitions should be returned as part of the computed
     *            partitioning
     * @return the partitioning of the range
     */
    ITypedRegion[] computePartitioning(int offset, int length, bool includeZeroLengthPartitions);
}
