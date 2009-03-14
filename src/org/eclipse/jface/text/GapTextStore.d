/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module org.eclipse.jface.text.GapTextStore;

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
import org.eclipse.jface.text.IDocumentExtension3; // packageimport
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

import org.eclipse.core.runtime.Assert;


/**
 * Implements a gap managing text store. The gap text store relies on the assumption that
 * consecutive changes to a document are co-located. The start of the gap is always moved to the
 * location of the last change.
 * <p>
 * <strong>Performance:</strong> Typing-style changes perform in constant time unless re-allocation
 * becomes necessary. Generally, a change that does not cause re-allocation will cause at most one
 * {@linkplain System#arraycopy(Object, int, Object, int, int) arraycopy} operation of a length of
 * about <var>d</var>, where <var>d</var> is the distance from the previous change. Let <var>a(x)</var>
 * be the algorithmic performance of an <code>arraycopy</code> operation of the length <var>x</var>,
 * then such a change then performs in <i>O(a(x))</i>,
 * {@linkplain #get(int, int) get(int, <var>length</var>)} performs in <i>O(a(length))</i>,
 * {@link #get(int)} in <i>O(1)</i>.
 * <p>
 * How frequently the array needs re-allocation is controlled by the constructor parameters.
 * </p>
 * <p>
 * This class is not intended to be subclassed.
 * </p>
 *
 * @see CopyOnWriteTextStore for a copy-on-write text store wrapper
 * @noextend This class is not intended to be subclassed by clients.
 */
public class GapTextStore : ITextStore {
    /**
     * The minimum gap size allocated when re-allocation occurs.
     * @since 3.3
     */
    private const int fMinGapSize;
    /**
     * The maximum gap size allocated when re-allocation occurs.
     * @since 3.3
     */
    private const int fMaxGapSize;
    /**
     * The multiplier to compute the array size from the content length
     * (1&nbsp;&lt;=&nbsp;fSizeMultiplier&nbsp;&lt;=&nbsp;2).
     *
     * @since 3.3
     */
    private const float fSizeMultiplier;

    /** The store's content */
    private char[] fContent;
    /** Starting index of the gap */
    private int fGapStart= 0;
    /** End index of the gap */
    private int fGapEnd= 0;
    /**
     * The current high water mark. If a change would cause the gap to grow larger than this, the
     * array is re-allocated.
     * @since 3.3
     */
    private int fThreshold= 0;

    /**
     * Creates a new empty text store using the specified low and high watermarks.
     *
     * @param lowWatermark unused - at the lower bound, the array is only resized when the content
     *        does not fit
     * @param highWatermark if the gap is ever larger than this, it will automatically be shrunken
     *        (&gt;=&nbsp;0)
     * @deprecated use {@link GapTextStore#GapTextStore(int, int, float)} instead
     */
    public this(int lowWatermark, int highWatermark) {
        /*
         * Legacy constructor. The API contract states that highWatermark is the upper bound for the
         * gap size. Albeit this contract was not previously adhered to, it is now: The allocated
         * gap size is fixed at half the highWatermark. Since the threshold is always twice the
         * allocated gap size, the gap will never grow larger than highWatermark. Previously, the
         * gap size was initialized to highWatermark, causing re-allocation if the content length
         * shrunk right after allocation. The fixed gap size is now only half of the previous value,
         * circumventing that problem (there was no API contract specifying the initial gap size).
         *
         * The previous implementation did not allow the gap size to become smaller than
         * lowWatermark, which doesn't make any sense: that area of the gap was simply never ever
         * used.
         */
        this(highWatermark / 2, highWatermark / 2, 0f);
    }

    /**
     * Equivalent to
     * {@linkplain GapTextStore#GapTextStore(int, int, float) new GapTextStore(256, 4096, 0.1f)}.
     *
     * @since 3.3
     */
    public this() {
        this(256, 4096, 0.1f);
    }

    /**
     * Creates an empty text store that uses re-allocation thresholds relative to the content
     * length. Re-allocation is controlled by the <em>gap factor</em>, which is the quotient of
     * the gap size and the array size. Re-allocation occurs if a change causes the gap factor to go
     * outside <code>[0,&nbsp;maxGapFactor]</code>. When re-allocation occurs, the array is sized
     * such that the gap factor is <code>0.5 * maxGapFactor</code>. The gap size computed in this
     * manner is bounded by the <code>minSize</code> and <code>maxSize</code> parameters.
     * <p>
     * A <code>maxGapFactor</code> of <code>0</code> creates a text store that never has a gap
     * at all (if <code>minSize</code> is 0); a <code>maxGapFactor</code> of <code>1</code>
     * creates a text store that doubles its size with every re-allocation and that never shrinks.
     * </p>
     * <p>
     * The <code>minSize</code> and <code>maxSize</code> parameters are absolute bounds to the
     * allocated gap size. Use <code>minSize</code> to avoid frequent re-allocation for small
     * documents. Use <code>maxSize</code> to avoid a huge gap being allocated for large
     * documents.
     * </p>
     *
     * @param minSize the minimum gap size to allocate (&gt;=&nbsp;0; use 0 for no minimum)
     * @param maxSize the maximum gap size to allocate (&gt;=&nbsp;minSize; use
     *        {@link Integer#MAX_VALUE} for no maximum)
     * @param maxGapFactor is the maximum fraction of the array that is occupied by the gap (<code>0&nbsp;&lt;=&nbsp;maxGapFactor&nbsp;&lt;=&nbsp;1</code>)
     * @since 3.3
     */
    public this(int minSize, int maxSize, float maxGapFactor) {
        Assert.isLegal(0f <= maxGapFactor && maxGapFactor <= 1f);
        Assert.isLegal(0 <= minSize && minSize <= maxSize);
        fMinGapSize= minSize;
        fMaxGapSize= maxSize;
        fSizeMultiplier= 1 / (1 - maxGapFactor / 2);
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#get(int)
     */
    public final char get(int offset) {
        if (offset < fGapStart)
            return fContent[offset];

        return fContent[offset + gapSize()];
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#get(int, int)
     */
    public final String get(int offset, int length) {
        if (fGapStart <= offset)
            return new_String(fContent, offset + gapSize() , length);

        final int end= offset + length;

        if (end <= fGapStart)
            return new_String(fContent, offset, length);

        StringBuffer buf= new StringBuffer(length);
        buf.append(fContent[ offset .. fGapStart ]);
        buf.append(fContent[ fGapEnd .. end - fGapStart + fGapEnd ]);
        return buf.toString();
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#getLength()
     */
    public final int getLength() {
        return fContent.length - gapSize();
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#set(java.lang.String)
     */
    public final void set(String text) {
        /*
         * Moves the gap to the end of the content. There is no sensible prediction of where the
         * next change will occur, but at least the next change will not trigger re-allocation. This
         * is especially important when using the GapTextStore within a CopyOnWriteTextStore, where
         * the GTS is only initialized right before a modification.
         */
        replace(0, getLength(), text);
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#replace(int, int, java.lang.String)
     */
    public final void replace(int offset, int length, String text) {
        if (text is null) {
            adjustGap(offset, length, 0);
        } else {
            int textLength= text.length;
            adjustGap(offset, length, textLength);
            if (textLength !is 0)
                text.getChars(0, textLength, fContent, offset);
        }
    }

    /**
     * Moves the gap to <code>offset + add</code>, moving any content after
     * <code>offset + remove</code> behind the gap. The gap size is kept between 0 and
     * {@link #fThreshold}, leading to re-allocation if needed. The content between
     * <code>offset</code> and <code>offset + add</code> is undefined after this operation.
     *
     * @param offset the offset at which a change happens
     * @param remove the number of character which are removed or overwritten at <code>offset</code>
     * @param add the number of character which are inserted or overwriting at <code>offset</code>
     */
    private void adjustGap(int offset, int remove, int add) {
        final int oldGapSize= gapSize();
        final int newGapSize= oldGapSize - add + remove;
        final bool reuseArray= 0 <= newGapSize && newGapSize <= fThreshold;

        final int newGapStart= offset + add;
        int newGapEnd;

        if (reuseArray)
            newGapEnd= moveGap(offset, remove, oldGapSize, newGapSize, newGapStart);
        else
            newGapEnd= reallocate(offset, remove, oldGapSize, newGapSize, newGapStart);

        fGapStart= newGapStart;
        fGapEnd= newGapEnd;
    }

    /**
     * Moves the gap to <code>newGapStart</code>.
     *
     * @param offset the change offset
     * @param remove the number of removed / overwritten characters
     * @param oldGapSize the old gap size
     * @param newGapSize the gap size after the change
     * @param newGapStart the offset in the array to move the gap to
     * @return the new gap end
     * @since 3.3
     */
    private int moveGap(int offset, int remove, int oldGapSize, int newGapSize, int newGapStart) {
        /*
         * No re-allocation necessary. The area between the change offset and gap can be copied
         * in at most one operation. Don't copy parts that will be overwritten anyway.
         */
        final int newGapEnd= newGapStart + newGapSize;
        if (offset < fGapStart) {
            int afterRemove= offset + remove;
            if (afterRemove < fGapStart) {
                final int betweenSize= fGapStart - afterRemove;
                arrayCopy(afterRemove, fContent, newGapEnd, betweenSize);
            }
            // otherwise, only the gap gets enlarged
        } else {
            final int offsetShifted= offset + oldGapSize;
            final int betweenSize= offsetShifted - fGapEnd; // in the typing case, betweenSize is 0
            arrayCopy(fGapEnd, fContent, fGapStart, betweenSize);
        }
        return newGapEnd;
    }

    /**
     * Reallocates a new array and copies the data from the previous one.
     *
     * @param offset the change offset
     * @param remove the number of removed / overwritten characters
     * @param oldGapSize the old gap size
     * @param newGapSize the gap size after the change if no re-allocation would occur (can be negative)
     * @param newGapStart the offset in the array to move the gap to
     * @return the new gap end
     * @since 3.3
     */
    private int reallocate(int offset, int remove, int oldGapSize, int newGapSize, int newGapStart) {
        // the new content length (without any gap)
        final int newLength= fContent.length - newGapSize;
        // the new array size based on the gap factor
        int newArraySize= cast(int) (newLength * fSizeMultiplier);
        newGapSize= newArraySize - newLength;

        // bound the gap size within min/max
        if (newGapSize < fMinGapSize) {
            newGapSize= fMinGapSize;
            newArraySize= newLength + newGapSize;
        } else if (newGapSize > fMaxGapSize) {
            newGapSize= fMaxGapSize;
            newArraySize= newLength + newGapSize;
        }

        // the upper threshold is always twice the gapsize
        fThreshold= newGapSize * 2;
        final char[] newContent= allocate(newArraySize);
        final int newGapEnd= newGapStart + newGapSize;

        /*
         * Re-allocation: The old content can be copied in at most 3 operations to the newly allocated
         * array. Either one of change offset and the gap may come first.
         * - unchanged area before the change offset / gap
         * - area between the change offset and the gap (either one may be first)
         * - rest area after the change offset / after the gap
         */
        if (offset < fGapStart) {
            // change comes before gap
            arrayCopy(0, newContent, 0, offset);
            int afterRemove= offset + remove;
            if (afterRemove < fGapStart) {
                // removal is completely before the gap
                final int betweenSize= fGapStart - afterRemove;
                arrayCopy(afterRemove, newContent, newGapEnd, betweenSize);
                final int restSize= fContent.length - fGapEnd;
                arrayCopy(fGapEnd, newContent, newGapEnd + betweenSize, restSize);
            } else {
                // removal encompasses the gap
                afterRemove += oldGapSize;
                final int restSize= fContent.length - afterRemove;
                arrayCopy(afterRemove, newContent, newGapEnd, restSize);
            }
        } else {
            // gap comes before change
            arrayCopy(0, newContent, 0, fGapStart);
            final int offsetShifted= offset + oldGapSize;
            final int betweenSize= offsetShifted - fGapEnd;
            arrayCopy(fGapEnd, newContent, fGapStart, betweenSize);
            final int afterRemove= offsetShifted + remove;
            final int restSize= fContent.length - afterRemove;
            arrayCopy(afterRemove, newContent, newGapEnd, restSize);
        }

        fContent= newContent;
        return newGapEnd;
    }

    /**
     * Allocates a new <code>char[size]</code>.
     *
     * @param size the length of the new array.
     * @return a newly allocated char array
     * @since 3.3
     */
    private char[] allocate(int size) {
        return new char[size];
    }

    /*
     * Executes System.arraycopy if length !is 0. A length < 0 cannot happen -> don't hide coding
     * errors by checking for negative lengths.
     * @since 3.3
     */
    private void arrayCopy(int srcPos, char[] dest, int destPos, int length) {
        if (length !is 0)
            System.arraycopy(fContent, srcPos, dest, destPos, length);
    }

    /**
     * Returns the gap size.
     *
     * @return the gap size
     * @since 3.3
     */
    private int gapSize() {
        return fGapEnd - fGapStart;
    }

    /**
     * Returns a copy of the content of this text store.
     * For internal use only.
     *
     * @return a copy of the content of this text store
     */
    protected String getContentAsString() {
        return new_String(fContent);
    }

    /**
     * Returns the start index of the gap managed by this text store.
     * For internal use only.
     *
     * @return the start index of the gap managed by this text store
     */
    protected int getGapStartIndex() {
        return fGapStart;
    }

    /**
     * Returns the end index of the gap managed by this text store.
     * For internal use only.
     *
     * @return the end index of the gap managed by this text store
     */
    protected int getGapEndIndex() {
        return fGapEnd;
    }
}