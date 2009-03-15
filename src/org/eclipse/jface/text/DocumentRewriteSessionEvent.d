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
module org.eclipse.jface.text.DocumentRewriteSessionEvent;
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
import org.eclipse.jface.text.IDocumentPartitionerExtension2;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.TreeLineTracker;



import java.lang.all;

import org.eclipse.core.runtime.Assert;


/**
 * Description of the state of document rewrite sessions.
 *
 * @see org.eclipse.jface.text.IDocument
 * @see org.eclipse.jface.text.IDocumentExtension4
 * @see org.eclipse.jface.text.IDocumentRewriteSessionListener
 * @since 3.1
 */
public class DocumentRewriteSessionEvent {

    private static Object SESSION_START_;
    public static Object SESSION_START(){
        if( SESSION_START_ is null ){
            synchronized(DocumentRewriteSessionEvent.classinfo){
                if( SESSION_START_ is null ){
                    SESSION_START_ = new Object();
                }
            }
        }
        return SESSION_START_;
    }
    private static Object SESSION_STOP_;
    public static Object SESSION_STOP(){
        if( SESSION_STOP_ is null ){
            synchronized(DocumentRewriteSessionEvent.classinfo){
                if( SESSION_STOP_ is null ){
                    SESSION_STOP_ = new Object();
                }
            }
        }
        return SESSION_STOP_;
    }

    /** The changed document */
    public IDocument fDocument;
    /** The session */
    public DocumentRewriteSession fSession;
    /** The change type */
    public Object fChangeType;

    /**
     * Creates a new document event.
     *
     * @param doc the changed document
     * @param session the session
     * @param changeType the change type. This is either
     *            {@link DocumentRewriteSessionEvent#SESSION_START} or
     *            {@link DocumentRewriteSessionEvent#SESSION_STOP}.
     */
    public this(IDocument doc, DocumentRewriteSession session, Object changeType) {
        Assert.isNotNull(cast(Object)doc);
        Assert.isNotNull(session);

        fDocument= doc;
        fSession= session;
        fChangeType= changeType;
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
     * Returns the change type of this event. This is either
     * {@link DocumentRewriteSessionEvent#SESSION_START}or
     * {@link DocumentRewriteSessionEvent#SESSION_STOP}.
     *
     * @return the change type of this event
     */
    public Object getChangeType() {
        return fChangeType;
    }

    /**
     * Returns the rewrite session.
     *
     * @return the rewrite session
     */
    public DocumentRewriteSession getSession() {
        return fSession;
    }
}
