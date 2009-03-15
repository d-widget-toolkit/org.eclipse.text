/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Anton Leherbauer (anton.leherbauer@windriver.com) - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.jface.text.CopyOnWriteTextStore;
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
 * Copy-on-write <code>ITextStore</code> wrapper.
 * <p>
 * This implementation uses an unmodifiable text store for the initial content.
 * Upon first modification attempt, the unmodifiable store is replaced with
 * a modifiable instance which must be supplied in the constructor.</p>
 * <p>
 * This class is not intended to be subclassed.
 * </p>
 *
 * @since 3.2
 * @noextend This class is not intended to be subclassed by clients.
 */
public class CopyOnWriteTextStore : ITextStore {

    /**
     * An unmodifiable String based text store. It is not possible to modify the content
     * other than using {@link #set}. Trying to {@link #replace} a text range will
     * throw an <code>UnsupportedOperationException</code>.
     */
    private static class StringTextStore : ITextStore {

        /** Represents the content of this text store. */
        private String fText= ""; //$NON-NLS-1$

        /**
         * Create an empty text store.
         */
        private this() {
//             super();
        }

        /**
         * Create a text store with initial content.
         * @param text  the initial content
         */
        private this(String text) {
//             super();
            set(text);
        }

        /*
         * @see org.eclipse.jface.text.ITextStore#get(int)
         */
        public char get(int offset) {
            return fText.charAt(offset);
        }

        /*
         * @see org.eclipse.jface.text.ITextStore#get(int, int)
         */
        public String get(int offset, int length) {
            return fText.substring(offset, offset + length);
        }

        /*
         * @see org.eclipse.jface.text.ITextStore#getLength()
         */
        public int getLength() {
            return fText.length();
        }

        /*
         * @see org.eclipse.jface.text.ITextStore#replace(int, int, java.lang.String)
         */
        public void replace(int offset, int length, String text) {
            // modification not supported
            throw new UnsupportedOperationException();
        }

        /*
         * @see org.eclipse.jface.text.ITextStore#set(java.lang.String)
         */
        public void set(String text) {
            fText= text !is null ? text : ""; //$NON-NLS-1$
        }

    }

    /** The underlying "real" text store */
    protected ITextStore fTextStore;

    /** A modifiable <code>ITextStore</code> instance */
    private const ITextStore fModifiableTextStore;

    /**
     * Creates an empty text store. The given text store will be used upon first
     * modification attempt.
     *
     * @param modifiableTextStore
     *            a modifiable <code>ITextStore</code> instance, may not be
     *            <code>null</code>
     */
    public this(ITextStore modifiableTextStore) {
        Assert.isNotNull(cast(Object)modifiableTextStore);
        fTextStore= new StringTextStore();
        fTextStore= new StringTextStore();
        fModifiableTextStore= modifiableTextStore;
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#get(int)
     */
    public char get(int offset) {
        return fTextStore.get(offset);
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#get(int, int)
     */
    public String get(int offset, int length) {
        return fTextStore.get(offset, length);
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#getLength()
     */
    public int getLength() {
        return fTextStore.getLength();
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#replace(int, int, java.lang.String)
     */
    public void replace(int offset, int length, String text) {
        if (fTextStore !is fModifiableTextStore) {
            String content= fTextStore.get(0, fTextStore.getLength());
            fTextStore= fModifiableTextStore;
            fTextStore.set(content);
        }
        fTextStore.replace(offset, length, text);
    }

    /*
     * @see org.eclipse.jface.text.ITextStore#set(java.lang.String)
     */
    public void set(String text) {
        fTextStore= new StringTextStore(text);
        fModifiableTextStore.set(""); //$NON-NLS-1$
    }

}
