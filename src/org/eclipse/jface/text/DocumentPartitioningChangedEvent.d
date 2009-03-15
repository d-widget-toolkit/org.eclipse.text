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
module org.eclipse.jface.text.DocumentPartitioningChangedEvent;
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
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;




import org.eclipse.core.runtime.Assert;

/**
 * Event describing the change of document partitionings.
 *
 * @see org.eclipse.jface.text.IDocumentExtension3
 * @since 3.0
 */
public class DocumentPartitioningChangedEvent {

    /** The document whose partitionings changed */
    private const IDocument fDocument;
    /** The map of partitionings to changed regions. */
    private const Map fMap;


    /**
     * Creates a new document partitioning changed event for the given document.
     * Initially this event is empty, i.e. does not describe any change.
     *
     * @param document the changed document
     */
    public this(IDocument document) {
        fMap= new HashMap();
        fDocument= document;
    }

    /**
     * Returns the changed document.
     *
     * @return the changed document
     */
    public IDocument getDocument() {
        return fDocument;
    }

    /**
     * Returns the changed region of the given partitioning or <code>null</code>
     * if the given partitioning did not change.
     *
     * @param partitioning the partitioning
     * @return the changed region of the given partitioning or <code>null</code>
     */
    public IRegion getChangedRegion(String partitioning) {
        return cast(IRegion) fMap.get(partitioning);
    }

    /**
     * Returns the set of changed partitionings.
     *
     * @return the set of changed partitionings
     */
    public String[] getChangedPartitionings() {
        return stringcast(fMap.keySet().toArray());
    }

    /**
     * Sets the specified range as changed region for the given partitioning.
     *
     * @param partitioning the partitioning
     * @param offset the region offset
     * @param length the region length
     */
    public void setPartitionChange(String partitioning, int offset, int length) {
        //Assert.isNotNull(partitioning);
        fMap.put(partitioning, new Region(offset, length));
    }

    /**
     * Returns <code>true</code> if the set of changed partitionings is empty,
     * <code>false</code> otherwise.
     *
     * @return <code>true</code> if the set of changed partitionings is empty
     */
    public bool isEmpty() {
        return fMap.isEmpty();
    }

    /**
     * Returns the coverage of this event. This is the minimal region that
     * contains all changed regions of all changed partitionings.
     *
     * @return the coverage of this event
     */
    public IRegion getCoverage() {
        if (fMap.isEmpty())
            return new Region(0, 0);

        int offset= -1;
        int endOffset= -1;
        Iterator e= fMap.values().iterator();
        while (e.hasNext()) {
            IRegion r= cast(IRegion) e.next();

            if (offset < 0 || r.getOffset() < offset)
                offset= r.getOffset();

            int end= r.getOffset() + r.getLength();
            if (end > endOffset)
                endOffset= end;
        }

        return new Region(offset, endOffset - offset);
    }
}
