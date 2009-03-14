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
module org.eclipse.jface.text.SequentialRewriteTextStore;

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
import org.eclipse.jface.text.DocumentRewriteSessionType; // packageimport
import org.eclipse.jface.text.TextAttribute; // packageimport
import org.eclipse.jface.text.ITextViewerExtension4; // packageimport
import org.eclipse.jface.text.ITypedRegion; // packageimport


import java.lang.all;
import java.util.LinkedList;
import java.util.Iterator;
import java.util.Set;





/**
 * A text store that optimizes a given source text store for sequential rewriting.
 * While rewritten it keeps a list of replace command that serve as patches for
 * the source store. Only on request, the source store is indeed manipulated
 * by applying the patch commands to the source text store.
 *
 * @since 2.0
 * @deprecated since 3.3 as {@link GapTextStore} performs better even for sequential rewrite scenarios
 */
public class SequentialRewriteTextStore : ITextStore {

    /**
     * A buffered replace command.
     */
    private static class Replace {
        public int newOffset;
        public const int offset;
        public const int length;
        public const String text;

        public this(int offset, int newOffset, int length, String text) {
            this.newOffset= newOffset;
            this.offset= offset;
            this.length= length;
            this.text= text;
        }
    }

    /** The list of buffered replacements. */
    private LinkedList fReplaceList;
    /** The source text store */
    private ITextStore fSource;
    /** A flag to enforce sequential access. */
    private static const bool ASSERT_SEQUENTIALITY= false;


    /**
     * Creates a new sequential rewrite store for the given source store.
     *
     * @param source the source text store
     */
    public this(ITextStore source) {
        fReplaceList= new LinkedList();
        fSource= source;
    }

    /**
     * Returns the source store of this rewrite store.
     *
     * @return  the source store of this rewrite store
     */
    public ITextStore getSourceStore() {
        commit();
        return fSource;
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#replace(int, int, java.lang.String)
     */
    public void replace(int offset, int length, String text) {
        if (text is null)
            text= ""; //$NON-NLS-1$

        if (fReplaceList.size() is 0) {
            fReplaceList.add(new Replace(offset, offset, length, text));

        } else {
            Replace firstReplace= cast(Replace) fReplaceList.getFirst();
            Replace lastReplace= cast(Replace) fReplaceList.getLast();

            // backward
            if (offset + length <= firstReplace.newOffset) {
                int delta= text.length - length;
                if (delta !is 0) {
                    for (Iterator i= fReplaceList.iterator(); i.hasNext(); ) {
                        Replace replace= cast(Replace) i.next();
                        replace.newOffset += delta;
                    }
                }

                fReplaceList.addFirst(new Replace(offset, offset, length, text));

            // forward
            } else if (offset >= lastReplace.newOffset + lastReplace.text.length) {
                int delta= getDelta(lastReplace);
                fReplaceList.add(new Replace(offset - delta, offset, length, text));

            } else if (ASSERT_SEQUENTIALITY) {
                throw new IllegalArgumentException(null);

            } else {
                commit();
                fSource.replace(offset, length, text);
            }
        }
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#set(java.lang.String)
     */
    public void set(String text) {
        fSource.set(text);
        fReplaceList.clear();
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#get(int, int)
     */
    public String get(int offset, int length) {

        if (fReplaceList.isEmpty())
            return fSource.get(offset, length);


        Replace firstReplace= cast(Replace) fReplaceList.getFirst();
        Replace lastReplace= cast(Replace) fReplaceList.getLast();

        // before
        if (offset + length <= firstReplace.newOffset) {
            return fSource.get(offset, length);

            // after
        } else if (offset >= lastReplace.newOffset + lastReplace.text.length) {
            int delta= getDelta(lastReplace);
            return fSource.get(offset - delta, length);

        } else if (ASSERT_SEQUENTIALITY) {
            throw new IllegalArgumentException(null);

        } else {

            int delta= 0;
            for (Iterator i= fReplaceList.iterator(); i.hasNext(); ) {
                Replace replace= cast(Replace) i.next();

                if (offset + length < replace.newOffset) {
                    return fSource.get(offset - delta, length);

                } else if (offset >= replace.newOffset && offset + length <= replace.newOffset + replace.text.length) {
                    return replace.text.substring(offset - replace.newOffset, offset - replace.newOffset + length);

                } else if (offset >= replace.newOffset + replace.text.length) {
                    delta= getDelta(replace);
                    continue;

                } else {
                    commit();
                    return fSource.get(offset, length);
                }
            }

            return fSource.get(offset - delta, length);
        }

    }

    /**
     * Returns the difference between the offset in the source store and the "same" offset in the
     * rewrite store after the replace operation.
     *
     * @param replace the replace command
     * @return the difference
     */
    private static final int getDelta(Replace replace) {
        return replace.newOffset - replace.offset + replace.text.length() - replace.length;
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#get(int)
     */
    public char get(int offset) {
        if (fReplaceList.isEmpty())
            return fSource.get(offset);

        Replace firstReplace= cast(Replace) fReplaceList.getFirst();
        Replace lastReplace= cast(Replace) fReplaceList.getLast();

        // before
        if (offset < firstReplace.newOffset) {
            return fSource.get(offset);

            // after
        } else if (offset >= lastReplace.newOffset + lastReplace.text.length()) {
            int delta= getDelta(lastReplace);
            return fSource.get(offset - delta);

        } else if (ASSERT_SEQUENTIALITY) {
            throw new IllegalArgumentException(null);

        } else {

            int delta= 0;
            for (Iterator i= fReplaceList.iterator(); i.hasNext(); ) {
                Replace replace= cast(Replace) i.next();

                if (offset < replace.newOffset)
                    return fSource.get(offset - delta);

                else if (offset < replace.newOffset + replace.text.length())
                    return replace.text.charAt(offset - replace.newOffset);

                delta= getDelta(replace);
            }

            return fSource.get(offset - delta);
        }
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#getLength()
     */
    public int getLength() {
        if (fReplaceList.isEmpty())
            return fSource.getLength();

        Replace lastReplace= cast(Replace) fReplaceList.getLast();
        return fSource.getLength() + getDelta(lastReplace);
    }

    /**
     * Disposes this rewrite store.
     */
    public void dispose() {
        fReplaceList= null;
        fSource= null;
    }

    /**
     * Commits all buffered replace commands.
     */
    private void commit() {

        if (fReplaceList.isEmpty())
            return;

        StringBuffer buffer= new StringBuffer();

        int delta= 0;
        for (Iterator i= fReplaceList.iterator(); i.hasNext(); ) {
            Replace replace= cast(Replace) i.next();

            int offset= buffer.length() - delta;
            buffer.append(fSource.get(offset, replace.offset - offset));
            buffer.append(replace.text);
            delta= getDelta(replace);
        }

        int offset= buffer.length() - delta;
        buffer.append(fSource.get(offset, fSource.getLength() - offset));

        fSource.set(buffer.toString());
        fReplaceList.clear();
    }
}
