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

// import org.eclipse.jface.text.IDocumentPartitioningListener; // packageimport
// import org.eclipse.jface.text.DefaultTextHover; // packageimport
// import org.eclipse.jface.text.AbstractInformationControl; // packageimport
// import org.eclipse.jface.text.TextUtilities; // packageimport
// import org.eclipse.jface.text.IInformationControlCreatorExtension; // packageimport
// import org.eclipse.jface.text.AbstractInformationControlManager; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension2; // packageimport
// import org.eclipse.jface.text.IDocumentPartitioner; // packageimport
// import org.eclipse.jface.text.DefaultIndentLineAutoEditStrategy; // packageimport
// import org.eclipse.jface.text.ITextSelection; // packageimport
// import org.eclipse.jface.text.Document; // packageimport
// import org.eclipse.jface.text.FindReplaceDocumentAdapterContentProposalProvider; // packageimport
// import org.eclipse.jface.text.ITextListener; // packageimport
// import org.eclipse.jface.text.BadPartitioningException; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension5; // packageimport
// import org.eclipse.jface.text.IDocumentPartitionerExtension3; // packageimport
// import org.eclipse.jface.text.IUndoManager; // packageimport
// import org.eclipse.jface.text.ITextHoverExtension2; // packageimport
// import org.eclipse.jface.text.IRepairableDocument; // packageimport
// import org.eclipse.jface.text.IRewriteTarget; // packageimport
// import org.eclipse.jface.text.DefaultPositionUpdater; // packageimport
// import org.eclipse.jface.text.RewriteSessionEditProcessor; // packageimport
// import org.eclipse.jface.text.TextViewerHoverManager; // packageimport
// import org.eclipse.jface.text.DocumentRewriteSession; // packageimport
// import org.eclipse.jface.text.TextViewer; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension8; // packageimport
// import org.eclipse.jface.text.RegExMessages; // packageimport
// import org.eclipse.jface.text.IDelayedInputChangeProvider; // packageimport
// import org.eclipse.jface.text.ITextOperationTargetExtension; // packageimport
// import org.eclipse.jface.text.IWidgetTokenOwner; // packageimport
// import org.eclipse.jface.text.IViewportListener; // packageimport
// import org.eclipse.jface.text.GapTextStore; // packageimport
// import org.eclipse.jface.text.MarkSelection; // packageimport
// import org.eclipse.jface.text.IDocumentPartitioningListenerExtension; // packageimport
// import org.eclipse.jface.text.IDocumentAdapterExtension; // packageimport
// import org.eclipse.jface.text.IInformationControlExtension; // packageimport
// import org.eclipse.jface.text.IDocumentPartitioningListenerExtension2; // packageimport
// import org.eclipse.jface.text.DefaultDocumentAdapter; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension3; // packageimport
// import org.eclipse.jface.text.IInformationControlCreator; // packageimport
// import org.eclipse.jface.text.TypedRegion; // packageimport
// import org.eclipse.jface.text.ISynchronizable; // packageimport
// import org.eclipse.jface.text.IMarkRegionTarget; // packageimport
// import org.eclipse.jface.text.TextViewerUndoManager; // packageimport
// import org.eclipse.jface.text.IRegion; // packageimport
// import org.eclipse.jface.text.IInformationControlExtension2; // packageimport
import org.eclipse.jface.text.IDocumentExtension4; // packageimport
// import org.eclipse.jface.text.IDocumentExtension2; // packageimport
// import org.eclipse.jface.text.IDocumentPartitionerExtension2; // packageimport
// import org.eclipse.jface.text.Assert; // packageimport
// import org.eclipse.jface.text.DefaultInformationControl; // packageimport
// import org.eclipse.jface.text.IWidgetTokenOwnerExtension; // packageimport
// import org.eclipse.jface.text.DocumentClone; // packageimport
// import org.eclipse.jface.text.DefaultUndoManager; // packageimport
// import org.eclipse.jface.text.IFindReplaceTarget; // packageimport
// import org.eclipse.jface.text.IAutoEditStrategy; // packageimport
// import org.eclipse.jface.text.ILineTrackerExtension; // packageimport
// import org.eclipse.jface.text.IUndoManagerExtension; // packageimport
// import org.eclipse.jface.text.TextSelection; // packageimport
// import org.eclipse.jface.text.DefaultAutoIndentStrategy; // packageimport
// import org.eclipse.jface.text.IAutoIndentStrategy; // packageimport
// import org.eclipse.jface.text.IPainter; // packageimport
// import org.eclipse.jface.text.IInformationControl; // packageimport
// import org.eclipse.jface.text.IInformationControlExtension3; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension6; // packageimport
// import org.eclipse.jface.text.IInformationControlExtension4; // packageimport
// import org.eclipse.jface.text.DefaultLineTracker; // packageimport
// import org.eclipse.jface.text.IDocumentInformationMappingExtension; // packageimport
// import org.eclipse.jface.text.IRepairableDocumentExtension; // packageimport
// import org.eclipse.jface.text.ITextHover; // packageimport
// import org.eclipse.jface.text.FindReplaceDocumentAdapter; // packageimport
// import org.eclipse.jface.text.ILineTracker; // packageimport
// import org.eclipse.jface.text.Line; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension; // packageimport
// import org.eclipse.jface.text.IDocumentAdapter; // packageimport
// import org.eclipse.jface.text.TextEvent; // packageimport
// import org.eclipse.jface.text.BadLocationException; // packageimport
// import org.eclipse.jface.text.AbstractDocument; // packageimport
// import org.eclipse.jface.text.AbstractLineTracker; // packageimport
// import org.eclipse.jface.text.TreeLineTracker; // packageimport
// import org.eclipse.jface.text.ITextPresentationListener; // packageimport
// import org.eclipse.jface.text.Region; // packageimport
// import org.eclipse.jface.text.ITextViewer; // packageimport
// import org.eclipse.jface.text.IDocumentInformationMapping; // packageimport
// import org.eclipse.jface.text.MarginPainter; // packageimport
// import org.eclipse.jface.text.IPaintPositionManager; // packageimport
// import org.eclipse.jface.text.TextPresentation; // packageimport
// import org.eclipse.jface.text.IFindReplaceTargetExtension; // packageimport
// import org.eclipse.jface.text.ISlaveDocumentManagerExtension; // packageimport
// import org.eclipse.jface.text.ISelectionValidator; // packageimport
// import org.eclipse.jface.text.IDocumentExtension; // packageimport
// import org.eclipse.jface.text.PropagatingFontFieldEditor; // packageimport
// import org.eclipse.jface.text.ConfigurableLineTracker; // packageimport
// import org.eclipse.jface.text.SlaveDocumentEvent; // packageimport
// import org.eclipse.jface.text.IDocumentListener; // packageimport
// import org.eclipse.jface.text.PaintManager; // packageimport
// import org.eclipse.jface.text.IFindReplaceTargetExtension3; // packageimport
// import org.eclipse.jface.text.ITextDoubleClickStrategy; // packageimport
// import org.eclipse.jface.text.IDocumentExtension3; // packageimport
// import org.eclipse.jface.text.Position; // packageimport
// import org.eclipse.jface.text.TextMessages; // packageimport
// import org.eclipse.jface.text.CopyOnWriteTextStore; // packageimport
// import org.eclipse.jface.text.WhitespaceCharacterPainter; // packageimport
// import org.eclipse.jface.text.IPositionUpdater; // packageimport
// import org.eclipse.jface.text.DefaultTextDoubleClickStrategy; // packageimport
// import org.eclipse.jface.text.ListLineTracker; // packageimport
// import org.eclipse.jface.text.ITextInputListener; // packageimport
// import org.eclipse.jface.text.BadPositionCategoryException; // packageimport
// import org.eclipse.jface.text.IWidgetTokenKeeperExtension; // packageimport
// import org.eclipse.jface.text.IInputChangedListener; // packageimport
// import org.eclipse.jface.text.ITextOperationTarget; // packageimport
// import org.eclipse.jface.text.IDocumentInformationMappingExtension2; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension7; // packageimport
// import org.eclipse.jface.text.IInformationControlExtension5; // packageimport
// import org.eclipse.jface.text.IDocumentRewriteSessionListener; // packageimport
// import org.eclipse.jface.text.JFaceTextUtil; // packageimport
// import org.eclipse.jface.text.AbstractReusableInformationControlCreator; // packageimport
// import org.eclipse.jface.text.TabsToSpacesConverter; // packageimport
// import org.eclipse.jface.text.CursorLinePainter; // packageimport
// import org.eclipse.jface.text.ITextHoverExtension; // packageimport
// import org.eclipse.jface.text.IEventConsumer; // packageimport
import org.eclipse.jface.text.IDocument; // packageimport
// import org.eclipse.jface.text.IWidgetTokenKeeper; // packageimport
// import org.eclipse.jface.text.DocumentCommand; // packageimport
// import org.eclipse.jface.text.TypedPosition; // packageimport
// import org.eclipse.jface.text.IEditingSupportRegistry; // packageimport
// import org.eclipse.jface.text.IDocumentPartitionerExtension; // packageimport
// import org.eclipse.jface.text.AbstractHoverInformationControlManager; // packageimport
// import org.eclipse.jface.text.IEditingSupport; // packageimport
// import org.eclipse.jface.text.IMarkSelection; // packageimport
// import org.eclipse.jface.text.ISlaveDocumentManager; // packageimport
// import org.eclipse.jface.text.DocumentPartitioningChangedEvent; // packageimport
// import org.eclipse.jface.text.ITextStore; // packageimport
// import org.eclipse.jface.text.JFaceTextMessages; // packageimport
// import org.eclipse.jface.text.DocumentRewriteSessionEvent; // packageimport
// import org.eclipse.jface.text.SequentialRewriteTextStore; // packageimport
// import org.eclipse.jface.text.DocumentRewriteSessionType; // packageimport
// import org.eclipse.jface.text.TextAttribute; // packageimport
// import org.eclipse.jface.text.ITextViewerExtension4; // packageimport
// import org.eclipse.jface.text.ITypedRegion; // packageimport

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
