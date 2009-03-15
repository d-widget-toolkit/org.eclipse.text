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
import org.eclipse.jface.text.Line;
import org.eclipse.jface.text.DocumentRewriteSessionEvent;
import org.eclipse.jface.text.IDocumentPartitionerExtension2;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.TreeLineTracker;



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
