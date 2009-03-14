/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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
module org.eclipse.jface.text.projection.FragmentUpdater;
import org.eclipse.jface.text.projection.ChildDocumentManager;
import org.eclipse.jface.text.projection.IMinimalMapping;
import org.eclipse.jface.text.projection.Segment;
import org.eclipse.jface.text.projection.ChildDocument;
import org.eclipse.jface.text.projection.ProjectionMapping;
import org.eclipse.jface.text.projection.SegmentUpdater;
import org.eclipse.jface.text.projection.ProjectionDocumentEvent;
import org.eclipse.jface.text.projection.ProjectionTextStore;
import org.eclipse.jface.text.projection.ProjectionDocumentManager;
import org.eclipse.jface.text.projection.Fragment;
import org.eclipse.jface.text.projection.ProjectionDocument;



import java.lang.all;
import java.util.Set;


import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.BadPositionCategoryException;
import org.eclipse.jface.text.DefaultPositionUpdater;
import org.eclipse.jface.text.DocumentEvent;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.Position;


/**
 * The position updater used to adapt the fragments of a master document. If an
 * insertion happens at a fragment's offset, the fragment is extended rather
 * than shifted. Also, the last fragment is extended if an insert operation
 * happens at the end of the fragment.
 *
 * @since 3.0
 */
class FragmentUpdater : DefaultPositionUpdater {

    /** Indicates whether the position being updated represents the last fragment. */
    private bool fIsLast= false;

    /**
     * Creates the fragment updater for the given category.
     *
     * @param fragmentCategory the position category used for managing the fragments of a document
     */
    /+protected+/ this(String fragmentCategory) {
        super(fragmentCategory);
    }

    /*
     * @see org.eclipse.jface.text.IPositionUpdater#update(org.eclipse.jface.text.DocumentEvent)
     */
    public void update(DocumentEvent event) {

        try {

            Position[] category= event.getDocument().getPositions(getCategory());

            fOffset= event.getOffset();
            fLength= event.getLength();
            fReplaceLength= (event.getText() is null ? 0 : event.getText().length());
            fDocument= event.getDocument();

            for (int i= 0; i < category.length; i++) {

                fPosition= category[i];
                fIsLast= (i is category.length -1);

                fOriginalPosition.offset= fPosition.offset;
                fOriginalPosition.length= fPosition.length;

                if (notDeleted())
                    adaptToReplace();
            }

        } catch (BadPositionCategoryException x) {
            // do nothing
        }
    }

    /*
     * @see org.eclipse.jface.text.DefaultPositionUpdater#adaptToInsert()
     */
    protected void adaptToInsert() {
        int myStart= fPosition.offset;
        int myEnd= Math.max(myStart, fPosition.offset + fPosition.length - (fIsLast || isAffectingReplace() ? 0 : 1));

        if (myEnd < fOffset)
            return;

        if (fLength <= 0) {

            if (myStart <= fOffset)
                fPosition.length += fReplaceLength;
            else
                fPosition.offset += fReplaceLength;

        } else {

            if (myStart <= fOffset && fOriginalPosition.offset <= fOffset)
                fPosition.length += fReplaceLength;
            else
                fPosition.offset += fReplaceLength;
        }
    }

    /**
     * Returns whether this updater considers any position affected by the given document event. A
     * position is affected if <code>event</code> {@link Position#overlapsWith(int, int) overlaps}
     * with it but not if the position is only shifted.
     *
     * @param event the event
     * @return <code>true</code> if there is any affected position, <code>false</code> otherwise
     */
    public bool affectsPositions(DocumentEvent event) {
        IDocument document= event.getDocument();
        try {

            int index= document.computeIndexInCategory(getCategory(), event.getOffset());
            Position[] fragments= document.getPositions(getCategory());

            if (0 < index) {
                Position fragment= fragments[index - 1];
                if (fragment.overlapsWith(event.getOffset(), event.getLength()))
                    return true;
                if (index is fragments.length && fragment.offset + fragment.length is event.getOffset())
                    return true;
            }

            if (index < fragments.length) {
                Position fragment= fragments[index];
                return fragment.overlapsWith(event.getOffset(), event.getLength());
            }

        } catch (BadLocationException x) {
        } catch (BadPositionCategoryException x) {
        }

        return false;
    }
}
