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
module org.eclipse.jface.text.AbstractLineTracker;

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
import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Set;
import tango.text.convert.Format;



    /**
     * Combines the information of the occurrence of a line delimiter. <code>delimiterIndex</code>
     * is the index where a line delimiter starts, whereas <code>delimiterLength</code>,
     * indicates the length of the delimiter.
     */
    protected class DelimiterInfo {
        public int delimiterIndex;
        public int delimiterLength;
        public String delimiter;
    }
    alias DelimiterInfo AbstractLineTracker_DelimiterInfo;

/**
 * Abstract implementation of <code>ILineTracker</code>. It lets the definition of line
 * delimiters to subclasses. Assuming that '\n' is the only line delimiter, this abstract
 * implementation defines the following line scheme:
 * <ul>
 * <li> "" -> [0,0]
 * <li> "a" -> [0,1]
 * <li> "\n" -> [0,1], [1,0]
 * <li> "a\n" -> [0,2], [2,0]
 * <li> "a\nb" -> [0,2], [2,1]
 * <li> "a\nbc\n" -> [0,2], [2,3], [5,0]
 * </ul>
 * <p>
 * This class must be subclassed.
 * </p>
 */
public abstract class AbstractLineTracker : ILineTracker, ILineTrackerExtension {

    /**
     * Tells whether this class is in debug mode.
     *
     * @since 3.1
     */
    private static const bool DEBUG= false;

    /**
     * Representation of replace and set requests.
     *
     * @since 3.1
     */
    protected static class Request {
        public const int offset;
        public const int length;
        public const String text;

        public this(int offset, int length, String text) {
            this.offset= offset;
            this.length= length;
            this.text= text;
        }

        public this(String text) {
            this.offset= -1;
            this.length= -1;
            this.text= text;
        }

        public bool isReplaceRequest() {
            return this.offset > -1 && this.length > -1;
        }
    }

    /**
     * The active rewrite session.
     *
     * @since 3.1
     */
    private DocumentRewriteSession fActiveRewriteSession;
    /**
     * The list of pending requests.
     *
     * @since 3.1
     */
    private List fPendingRequests;
    /**
     * The implementation that this tracker delegates to.
     *
     * @since 3.2
     */
    private ILineTracker fDelegate;
    private void fDelegate_init() {
        fDelegate = new class() ListLineTracker {
            public String[] getLegalLineDelimiters() {
                return this.outer.getLegalLineDelimiters();
            }

            protected DelimiterInfo nextDelimiterInfo(String text, int offset) {
                return this.outer.nextDelimiterInfo(text, offset);
            }
        };
    }
    /**
     * Whether the delegate needs conversion when the line structure is modified.
     */
    private bool fNeedsConversion= true;

    /**
     * Creates a new line tracker.
     */
    protected this() {
        fDelegate_init();
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#computeNumberOfLines(java.lang.String)
     */
    public int computeNumberOfLines(String text) {
        return fDelegate.computeNumberOfLines(text);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineDelimiter(int)
     */
    public String getLineDelimiter(int line)  {
        checkRewriteSession();
        return fDelegate.getLineDelimiter(line);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineInformation(int)
     */
    public IRegion getLineInformation(int line)  {
        checkRewriteSession();
        return fDelegate.getLineInformation(line);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineInformationOfOffset(int)
     */
    public IRegion getLineInformationOfOffset(int offset)  {
        checkRewriteSession();
        return fDelegate.getLineInformationOfOffset(offset);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineLength(int)
     */
    public int getLineLength(int line)  {
        checkRewriteSession();
        return fDelegate.getLineLength(line);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineNumberOfOffset(int)
     */
    public int getLineNumberOfOffset(int offset)  {
        checkRewriteSession();
        return fDelegate.getLineNumberOfOffset(offset);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineOffset(int)
     */
    public int getLineOffset(int line)  {
        checkRewriteSession();
        return fDelegate.getLineOffset(line);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getNumberOfLines()
     */
    public int getNumberOfLines() {
        try {
            checkRewriteSession();
        } catch (BadLocationException x) {
            // TODO there is currently no way to communicate that exception back to the document
        }
        return fDelegate.getNumberOfLines();
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getNumberOfLines(int, int)
     */
    public int getNumberOfLines(int offset, int length)  {
        checkRewriteSession();
        return fDelegate.getNumberOfLines(offset, length);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#set(java.lang.String)
     */
    public void set(String text) {
        if (hasActiveRewriteSession()) {
            fPendingRequests.clear();
            fPendingRequests.add(new Request(text));
            return;
        }

        fDelegate.set(text);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#replace(int, int, java.lang.String)
     */
    public void replace(int offset, int length, String text)  {
        if (hasActiveRewriteSession()) {
            fPendingRequests.add(new Request(offset, length, text));
            return;
        }

        checkImplementation();

        fDelegate.replace(offset, length, text);
    }

    /**
     * Converts the implementation to be a {@link TreeLineTracker} if it isn't yet.
     *
     * @since 3.2
     */
    private void checkImplementation() {
        if (fNeedsConversion) {
            fNeedsConversion= false;
            fDelegate= new class(cast(ListLineTracker) fDelegate)  TreeLineTracker {
                this(ListLineTracker arg){
                    super(arg);
                }
                protected DelimiterInfo nextDelimiterInfo(String text, int offset) {
                    return this.outer.nextDelimiterInfo(text, offset);
                }

                public String[] getLegalLineDelimiters() {
                    return this.outer.getLegalLineDelimiters();
                }
            };
        }
    }

    /**
     * Returns the information about the first delimiter found in the given text starting at the
     * given offset.
     *
     * @param text the text to be searched
     * @param offset the offset in the given text
     * @return the information of the first found delimiter or <code>null</code>
     */
    protected abstract DelimiterInfo nextDelimiterInfo(String text, int offset);

    /*
     * @see org.eclipse.jface.text.ILineTrackerExtension#startRewriteSession(org.eclipse.jface.text.DocumentRewriteSession)
     * @since 3.1
     */
    public final void startRewriteSession(DocumentRewriteSession session) {
        if (fActiveRewriteSession !is null)
            throw new IllegalStateException();
        fActiveRewriteSession= session;
        fPendingRequests= new ArrayList(20);
    }

    /*
     * @see org.eclipse.jface.text.ILineTrackerExtension#stopRewriteSession(org.eclipse.jface.text.DocumentRewriteSession, java.lang.String)
     * @since 3.1
     */
    public final void stopRewriteSession(DocumentRewriteSession session, String text) {
        if (fActiveRewriteSession is session) {
            fActiveRewriteSession= null;
            fPendingRequests= null;
            set(text);
        }
    }

    /**
     * Tells whether there's an active rewrite session.
     *
     * @return <code>true</code> if there is an active rewrite session, <code>false</code>
     *         otherwise
     * @since 3.1
     */
    protected final bool hasActiveRewriteSession() {
        return fActiveRewriteSession !is null;
    }

    /**
     * Flushes the active rewrite session.
     *
     * @throws BadLocationException in case the recorded requests cannot be processed correctly
     * @since 3.1
     */
    protected final void flushRewriteSession()  {
        if (DEBUG)
            System.out_.println(Format("AbstractLineTracker: Flushing rewrite session: {}", fActiveRewriteSession)); //$NON-NLS-1$

        Iterator e= fPendingRequests.iterator();

        fPendingRequests= null;
        fActiveRewriteSession= null;

        while (e.hasNext()) {
            Request request= cast(Request) e.next();
            if (request.isReplaceRequest())
                replace(request.offset, request.length, request.text);
            else
                set(request.text);
        }
    }

    /**
     * Checks the presence of a rewrite session and flushes it.
     *
     * @throws BadLocationException in case flushing does not succeed
     * @since 3.1
     */
    protected final void checkRewriteSession()  {
        if (hasActiveRewriteSession())
            flushRewriteSession();
    }
}
