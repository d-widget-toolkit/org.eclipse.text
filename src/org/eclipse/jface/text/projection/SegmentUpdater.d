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
module org.eclipse.jface.text.projection.SegmentUpdater;
import org.eclipse.jface.text.projection.ChildDocumentManager;
import org.eclipse.jface.text.projection.IMinimalMapping;
import org.eclipse.jface.text.projection.Segment;
import org.eclipse.jface.text.projection.ChildDocument;
import org.eclipse.jface.text.projection.ProjectionMapping;
import org.eclipse.jface.text.projection.FragmentUpdater;
import org.eclipse.jface.text.projection.ProjectionDocumentEvent;
import org.eclipse.jface.text.projection.ProjectionTextStore;
import org.eclipse.jface.text.projection.ProjectionDocumentManager;
import org.eclipse.jface.text.projection.Fragment;
import org.eclipse.jface.text.projection.ProjectionDocument;



import java.lang.all;
import java.util.Set;



import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.text.BadPositionCategoryException;
import org.eclipse.jface.text.DefaultPositionUpdater;
import org.eclipse.jface.text.DocumentEvent;
import org.eclipse.jface.text.Position;


/**
 * The position updater used to adapt the segments of a projection document to
 * changes of the master document. Depending on the flags set on a segment, a
 * segment is either extended to shifted if an insertion happens at a segment's
 * offset. The last segment is extended if an insert operation happens at the
 * end of the segment.
 *
 * @since 3.0
 */
class SegmentUpdater : DefaultPositionUpdater {

    private Segment fNextSegment= null;
    private bool fIsProjectionChange= false;

    /**
     * Creates the segment updater for the given category.
     *
     * @param segmentCategory the position category used for managing the segments of a projection document
     */
    /+protected+/ this(String segmentCategory) {
        super(segmentCategory);
    }

    /*
     * @see org.eclipse.jface.text.IPositionUpdater#update(org.eclipse.jface.text.DocumentEvent)
     */
    public void update(DocumentEvent event) {

        Assert.isTrue( null !is cast(ProjectionDocumentEvent)event );
        fIsProjectionChange= (cast(ProjectionDocumentEvent) event).getChangeType() is ProjectionDocumentEvent.PROJECTION_CHANGE;

        try {

            Position[] category= event.getDocument().getPositions(getCategory());

            fOffset= event.getOffset();
            fLength= event.getLength();
            fReplaceLength= (event.getText() is null ? 0 : event.getText().length());
            fDocument= event.getDocument();

            for (int i= 0; i < category.length; i++) {

                fPosition= category[i];
                Assert.isTrue( null !is cast(Segment)fPosition );

                if (i < category.length - 1)
                    fNextSegment= cast(Segment) category[i + 1];
                else
                    fNextSegment= null;

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

        Segment segment= cast(Segment) fPosition;
        int myStart= segment.offset;
        int myEnd= segment.offset + segment.length - (segment.isMarkedForStretch || fNextSegment is null || isAffectingReplace() ? 0 : 1);
        myEnd= Math.max(myStart, myEnd);
        int yoursStart= fOffset;

        try {

            if (myEnd < yoursStart)
                return;

            if (segment.isMarkedForStretch) {
                Assert.isTrue(fIsProjectionChange);
                segment.isMarkedForShift= false;
                if (fNextSegment !is null) {
                    fNextSegment.isMarkedForShift= true;
                    fNextSegment.isMarkedForStretch= false;
                }
            }

            if (fLength <= 0) {

                if (myStart < (yoursStart + (segment.isMarkedForShift ? 0 : 1)))
                    fPosition.length += fReplaceLength;
                else
                    fPosition.offset += fReplaceLength;

            } else {

                if (myStart <= yoursStart && fOriginalPosition.offset <= yoursStart)
                    fPosition.length += fReplaceLength;
                else
                    fPosition.offset += fReplaceLength;
            }

        } finally {
            segment.clearMark();
        }
    }
}
