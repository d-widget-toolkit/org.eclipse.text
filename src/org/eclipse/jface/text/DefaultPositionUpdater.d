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
module org.eclipse.jface.text.DefaultPositionUpdater;

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
import org.eclipse.jface.text.SequentialRewriteTextStore; // packageimport
import org.eclipse.jface.text.DocumentRewriteSessionType; // packageimport
import org.eclipse.jface.text.TextAttribute; // packageimport
import org.eclipse.jface.text.ITextViewerExtension4; // packageimport
import org.eclipse.jface.text.ITypedRegion; // packageimport


import java.lang.all;
import java.util.Set;


/**
 * Default implementation of {@link org.eclipse.jface.text.IPositionUpdater}.
 * <p>
 * A default position updater must be configured with the position category whose positions it will
 * update. Other position categories are not affected by this updater.
 * </p>
 * <p>
 * This implementation follows the specification below:
 * </p>
 * <ul>
 * <li>Inserting or deleting text before the position shifts the position accordingly.</li>
 * <li>Inserting text at the position offset shifts the position accordingly.</li>
 * <li>Inserting or deleting text strictly contained by the position shrinks or stretches the
 * position.</li>
 * <li>Inserting or deleting text after a position does not affect the position.</li>
 * <li>Deleting text which strictly contains the position deletes the position. Note that the
 * position is not deleted if its only shrunken to length zero. To delete a position, the
 * modification must delete from <i>strictly before</i> to <i>strictly after</i> the position.</li>
 * <li>Replacing text overlapping with the position is considered as a sequence of first deleting
 * the replaced text and afterwards inserting the new text. Thus, a position might first be shifted
 * and shrunken and then be stretched.</li>
 * </ul>
 * This class can be used as is or be adapted by subclasses. Fields are protected to allow
 * subclasses direct access. Because of the frequency with which position updaters are used this is
 * a performance decision.
 */
public class DefaultPositionUpdater : IPositionUpdater {

    /** The position category the updater draws responsible for */
    private String fCategory;

    /** Caches the currently investigated position */
    protected Position fPosition;
    /**
     * Remembers the original state of the investigated position
     * @since 2.1
     */
    protected Position fOriginalPosition;
    /** Caches the offset of the replaced text */
    protected int fOffset;
    /** Caches the length of the replaced text */
    protected int fLength;
    /** Caches the length of the newly inserted text */
    protected int fReplaceLength;
    /** Catches the document */
    protected IDocument fDocument;


    /**
     * Creates a new default position updater for the given category.
     *
     * @param category the category the updater is responsible for
     */
    public this(String category) {
        fOriginalPosition= new Position(0, 0);
        fCategory= category;
    }

    /**
     * Returns the category this updater is responsible for.
     *
     * @return the category this updater is responsible for
     */
    protected String getCategory() {
        return fCategory;
    }

    /**
     * Returns whether the current event describes a well formed replace
     * by which the current position is directly affected.
     *
     * @return <code>true</code> the current position is directly affected
     * @since 3.0
     */
    protected bool isAffectingReplace() {
        return fLength > 0 && fReplaceLength > 0 && fPosition.length < fOriginalPosition.length;
    }

    /**
     * Adapts the currently investigated position to an insertion.
     */
    protected void adaptToInsert() {

        int myStart= fPosition.offset;
        int myEnd=   fPosition.offset + fPosition.length - 1;
        myEnd= Math.max(myStart, myEnd);

        int yoursStart= fOffset;
        int yoursEnd=   fOffset + fReplaceLength -1;
        yoursEnd= Math.max(yoursStart, yoursEnd);

        if (myEnd < yoursStart)
            return;

        if (fLength <= 0) {

            if (myStart < yoursStart)
                fPosition.length += fReplaceLength;
            else
                fPosition.offset += fReplaceLength;

        } else {

            if (myStart <= yoursStart && fOriginalPosition.offset <= yoursStart)
                fPosition.length += fReplaceLength;
            else
                fPosition.offset += fReplaceLength;
        }
    }

    /**
     * Adapts the currently investigated position to a deletion.
     */
    protected void adaptToRemove() {

        int myStart= fPosition.offset;
        int myEnd=   fPosition.offset + fPosition.length -1;
        myEnd= Math.max(myStart, myEnd);

        int yoursStart= fOffset;
        int yoursEnd=   fOffset + fLength -1;
        yoursEnd= Math.max(yoursStart, yoursEnd);

        if (myEnd < yoursStart)
            return;

        if (myStart <= yoursStart) {

            if (yoursEnd <= myEnd)
                fPosition.length -= fLength;
            else
                fPosition.length -= (myEnd - yoursStart +1);

        } else if (yoursStart < myStart) {

            if (yoursEnd < myStart)
                fPosition.offset -= fLength;
            else {
                fPosition.offset -= (myStart - yoursStart);
                fPosition.length -= (yoursEnd - myStart +1);
            }

        }

        // validate position to allowed values
        if (fPosition.offset < 0)
            fPosition.offset= 0;

        if (fPosition.length < 0)
            fPosition.length= 0;
    }

    /**
     * Adapts the currently investigated position to the replace operation.
     * First it checks whether the change replaces the whole range of the position.
     * If not, it performs first the deletion of the previous text and afterwards
     * the insertion of the new text.
     */
    protected void adaptToReplace() {

        if (fPosition.offset is fOffset && fPosition.length is fLength && fPosition.length > 0) {

            // replace the whole range of the position
            fPosition.length += (fReplaceLength - fLength);
            if (fPosition.length < 0) {
                fPosition.offset += fPosition.length;
                fPosition.length= 0;
            }

        } else {

            if (fLength >  0)
                adaptToRemove();

            if (fReplaceLength > 0)
                adaptToInsert();
        }
    }

    /**
     * Determines whether the currently investigated position has been deleted by
     * the replace operation specified in the current event. If so, it deletes
     * the position and removes it from the document's position category.
     *
     * @return <code>true</code> if position has not been deleted
     */
    protected bool notDeleted() {

        if (fOffset < fPosition.offset && (fPosition.offset + fPosition.length < fOffset + fLength)) {

            fPosition.delete_();

            try {
                fDocument.removePosition(fCategory, fPosition);
            } catch (BadPositionCategoryException x) {
            }

            return false;
        }

        return true;
    }

    /*
     * @see org.eclipse.jface.text.IPositionUpdater#update(org.eclipse.jface.text.DocumentEvent)
     */
    public void update(DocumentEvent event) {

        try {


            fOffset= event.getOffset();
            fLength= event.getLength();
            fReplaceLength= (event.getText() is null ? 0 : event.getText().length());
            fDocument= event.getDocument();

            Position[] category= fDocument.getPositions(fCategory);
            for (int i= 0; i < category.length; i++) {

                fPosition= category[i];
                fOriginalPosition.offset= fPosition.offset;
                fOriginalPosition.length= fPosition.length;

                if (notDeleted())
                    adaptToReplace();
            }

        } catch (BadPositionCategoryException x) {
            // do nothing
        } finally {
            fDocument= null;
        }
    }
}
