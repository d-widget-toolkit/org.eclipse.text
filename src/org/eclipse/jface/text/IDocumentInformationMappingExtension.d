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
module org.eclipse.jface.text.IDocumentInformationMappingExtension;
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
 * Extension to {@link org.eclipse.jface.text.IDocumentInformationMapping}.
 * <p>
 * Extends the information available in the mapping by providing explicit access
 * to the isomorphic portion of the basically homomorphic information mapping.
 *
 * @see org.eclipse.jface.text.IDocumentInformationMapping
 * @since 3.0
 */
public interface IDocumentInformationMappingExtension {

    /**
     * Adheres to
     * <code>originRegion=toOriginRegion(toExactImageRegion(originRegion))</code>,
     * if <code>toExactImageRegion(originRegion) !is null</code>. Returns
     * <code>null</code> if there is no image for the given origin region.
     *
     * @param originRegion the origin region
     * @return the exact image region or <code>null</code>
     * @throws BadLocationException if origin region is not a valid region in
     *             the origin document
     */
    IRegion toExactImageRegion(IRegion originRegion) ;

    /**
     * Returns the segments of the image document that exactly correspond to the
     * given region of the original document. Returns <code>null</code> if
     * there are no such image regions.
     *
     * @param originRegion the region in the origin document
     * @return the segments in the image document or <code>null</code>
     * @throws BadLocationException in case the given origin region is not valid
     *             in the original document
     */
    IRegion[] toExactImageRegions(IRegion originRegion) ;

    /**
     * Returns the fragments of the original document that exactly correspond to
     * the given region of the image document.
     *
     * @param imageRegion the region in the image document
     * @return the fragments in the origin document
     * @throws BadLocationException in case the given image region is not valid
     *             in the image document
     */
    IRegion[] toExactOriginRegions(IRegion imageRegion) ;

    /**
     * Returns the length of the image document.
     *
     * @return the length of the image document
     */
    int getImageLength();

    /**
     * Returns the maximal sub-regions of the given origin region which are
     * completely covered. I.e. each offset in a sub-region has a corresponding
     * image offset. Returns <code>null</code> if there are no such
     * sub-regions.
     *
     * @param originRegion the region in the origin document
     * @return the sub-regions with complete coverage or <code>null</code>
     * @throws BadLocationException in case the given origin region is not valid
     *             in the original document
     */
    IRegion[] getExactCoverage(IRegion originRegion) ;
}
