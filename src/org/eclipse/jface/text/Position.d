/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
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
module org.eclipse.jface.text.Position;
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

import org.eclipse.core.runtime.Assert;


/**
 * Positions describe text ranges of a document. Positions are adapted to
 * changes applied to that document. The text range is specified by an offset
 * and a length. Positions can be marked as deleted. Deleted positions are
 * considered to no longer represent a valid text range in the managing
 * document.
 * <p>
 * Positions attached to documents are usually updated by position updaters.
 * Because position updaters are freely definable and because of the frequency
 * in which they are used, the fields of a position are made publicly
 * accessible. Clients other than position updaters are not allowed to access
 * these public fields.
 * </p>
 * <p>
 * Positions cannot be used as keys in hash tables as they override
 * <code>equals</code> and <code>hashCode</code> as they would be value
 * objects.
 * </p>
 *
 * @see org.eclipse.jface.text.IDocument
 */
public class Position {

    /** The offset of the position */
    public int offset;
    /** The length of the position */
    public int length;
    /** Indicates whether the position has been deleted */
    public bool isDeleted_;

    /**
     * Creates a new position with the given offset and length 0.
     *
     * @param offset the position offset, must be >= 0
     */
    public this(int offset) {
        this(offset, 0);
    }

    /**
     * Creates a new position with the given offset and length.
     *
     * @param offset the position offset, must be >= 0
     * @param length the position length, must be >= 0
     */
    public this(int offset, int length) {
        Assert.isTrue(offset >= 0);
        Assert.isTrue(length >= 0);
        this.offset= offset;
        this.length= length;
    }

    /**
     * Creates a new, not initialized position.
     */
    protected this() {
    }

     /*
     * @see java.lang.Object#hashCode()
     */
    public override hash_t toHash() {
        int deleted= isDeleted_ ? 0 : 1;
        return (offset << 24) | (length << 16) | deleted;
     }

    /**
     * Marks this position as deleted.
     */
    public void delete_() {
        isDeleted_= true;
    }

    /**
     * Marks this position as not deleted.
     *
     * @since 2.0
     */
    public void undelete() {
        isDeleted_= false;
    }

    /*
     * @see java.lang.Object#equals(java.lang.Object)
     */
    public override int opEquals(Object other) {
        if ( auto rp = cast(Position)other ) {
            return (rp.offset is offset) && (rp.length is length);
        }
        return super.opEquals(other);
    }

    /**
     * Returns the length of this position.
     *
     * @return the length of this position
     */
    public int getLength() {
        return length;
    }

    /**
     * Returns the offset of this position.
     *
     * @return the offset of this position
     */
    public int getOffset() {
        return offset;
    }

    /**
     * Checks whether the given index is inside
     * of this position's text range.
     *
     * @param index the index to check
     * @return <code>true</code> if <code>index</code> is inside of this position
     */
    public bool includes(int index) {

        if (isDeleted_)
            return false;

        return (this.offset <= index) && (index < this.offset + length);
    }

    /**
     * Checks whether the intersection of the given text range
     * and the text range represented by this position is empty
     * or not.
     *
     * @param rangeOffset the offset of the range to check
     * @param rangeLength the length of the range to check
     * @return <code>true</code> if intersection is not empty
     */
    public bool overlapsWith(int rangeOffset, int rangeLength) {

        if (isDeleted_)
            return false;

        int end= rangeOffset + rangeLength;
        int thisEnd= this.offset + this.length;

        if (rangeLength > 0) {
            if (this.length > 0)
                return this.offset < end && rangeOffset < thisEnd;
            return  rangeOffset <= this.offset && this.offset < end;
        }

        if (this.length > 0)
            return this.offset <= rangeOffset && rangeOffset < thisEnd;
        return this.offset is rangeOffset;
    }

    /**
     * Returns whether this position has been deleted or not.
     *
     * @return <code>true</code> if position has been deleted
     */
    public bool isDeleted() {
        return isDeleted_;
    }

    /**
     * Changes the length of this position to the given length.
     *
     * @param length the new length of this position
     */
    public void setLength(int length) {
        Assert.isTrue(length >= 0);
        this.length= length;
    }

    /**
     * Changes the offset of this position to the given offset.
     *
     * @param offset the new offset of this position
     */
    public void setOffset(int offset) {
        Assert.isTrue(offset >= 0);
        this.offset= offset;
    }
}
