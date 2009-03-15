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
