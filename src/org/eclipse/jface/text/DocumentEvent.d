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


module org.eclipse.jface.text.DocumentEvent;
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

import org.eclipse.core.runtime.Assert;


/**
 * Specification of changes applied to documents. All changes are represented as
 * replace commands, i.e. specifying a document range whose text gets replaced
 * with different text. In addition to this information, the event also contains
 * the changed document.
 *
 * @see org.eclipse.jface.text.IDocument
 */
public class DocumentEvent {

    /**
     * Debug option for asserting that text is not null.
     * If the <code>org.eclipse.text/debug/DocumentEvent/assertTextNotNull</code>
     * system property is <code>true</code>
     *
     * @since 3.3
     */
    private static bool ASSERT_TEXT_NOT_NULL_init = false;
    private static bool ASSERT_TEXT_NOT_NULL_;
    private static bool ASSERT_TEXT_NOT_NULL(){
        if( !ASSERT_TEXT_NOT_NULL_init ){
            ASSERT_TEXT_NOT_NULL_init = true;
            ASSERT_TEXT_NOT_NULL_= Boolean.getBoolean("org.eclipse.text/debug/DocumentEvent/assertTextNotNull"); //$NON-NLS-1$
        }
        return ASSERT_TEXT_NOT_NULL_;
    }

    /** The changed document */
    public IDocument fDocument;
    /** The document offset */
    public int fOffset;
    /** Length of the replaced document text */
    public int fLength;
    /** Text inserted into the document */
    public String fText= ""; //$NON-NLS-1$
    /**
     * The modification stamp of the document when firing this event.
     * @since 3.1 and public since 3.3
     */
    public long fModificationStamp;

    /**
     * Creates a new document event.
     *
     * @param doc the changed document
     * @param offset the offset of the replaced text
     * @param length the length of the replaced text
     * @param text the substitution text
     */
    public this(IDocument doc, int offset, int length, String text) {

        Assert.isNotNull(cast(Object)doc);
        Assert.isTrue(offset >= 0);
        Assert.isTrue(length >= 0);

        if (ASSERT_TEXT_NOT_NULL)
            Assert.isNotNull(text);

        fDocument= doc;
        fOffset= offset;
        fLength= length;
        fText= text;

        if ( cast(IDocumentExtension4)fDocument )
            fModificationStamp= (cast(IDocumentExtension4)fDocument).getModificationStamp();
        else
            fModificationStamp= IDocumentExtension4.UNKNOWN_MODIFICATION_STAMP;
    }

    /**
     * Creates a new, not initialized document event.
     */
    public this() {
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
     * Returns the offset of the change.
     *
     * @return the offset of the change
     */
    public int getOffset() {
        return fOffset;
    }

    /**
     * Returns the length of the replaced text.
     *
     * @return the length of the replaced text
     */
    public int getLength() {
        return fLength;
    }

    /**
     * Returns the text that has been inserted.
     *
     * @return the text that has been inserted
     */
    public String getText() {
        return fText;
    }

    /**
     * Returns the document's modification stamp at the
     * time when this event was sent.
     *
     * @return the modification stamp or {@link IDocumentExtension4#UNKNOWN_MODIFICATION_STAMP}.
     * @see IDocumentExtension4#getModificationStamp()
     * @since 3.1
     */
    public long getModificationStamp() {
        return fModificationStamp;
    }

    /*
     * @see java.lang.Object#toString()
     * @since 3.4
     */
    public override String toString() {
        StringBuffer buffer= new StringBuffer();
        buffer.append("offset: " ); //$NON-NLS-1$
        buffer.append(fOffset);
        buffer.append(", length: " ); //$NON-NLS-1$
        buffer.append(fLength);
        buffer.append(", timestamp: " ); //$NON-NLS-1$
        buffer.append(fModificationStamp);
        buffer.append("\ntext:>" ); //$NON-NLS-1$
        buffer.append(fText);
        buffer.append("<\n" ); //$NON-NLS-1$
        return buffer.toString();
    }
}
