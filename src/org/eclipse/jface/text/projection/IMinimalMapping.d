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
module org.eclipse.jface.text.projection.IMinimalMapping;
import org.eclipse.jface.text.projection.ChildDocumentManager;
import org.eclipse.jface.text.projection.Segment;
import org.eclipse.jface.text.projection.ChildDocument;
import org.eclipse.jface.text.projection.ProjectionMapping;
import org.eclipse.jface.text.projection.FragmentUpdater;
import org.eclipse.jface.text.projection.SegmentUpdater;
import org.eclipse.jface.text.projection.ProjectionDocumentEvent;
import org.eclipse.jface.text.projection.ProjectionTextStore;
import org.eclipse.jface.text.projection.ProjectionDocumentManager;
import org.eclipse.jface.text.projection.Fragment;
import org.eclipse.jface.text.projection.ProjectionDocument;



import java.lang.all;
import java.util.Set;


import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IRegion;


/**
 * Internal interface for defining the exact subset of
 * {@link org.eclipse.jface.text.projection.ProjectionMapping} that the
 * {@link org.eclipse.jface.text.projection.ProjectionTextStore} is allowed to
 * access.
 *
 * @since 3.0
 */
interface IMinimalMapping {

    /*
     * @see org.eclipse.jface.text.IDocumentInformationMapping#getCoverage()
     */
    IRegion getCoverage();

    /*
     * @see org.eclipse.jface.text.IDocumentInformationMapping#toOriginRegion(IRegion)
     */
    IRegion toOriginRegion(IRegion region) ;

    /*
     * @see org.eclipse.jface.text.IDocumentInformationMapping#toOriginOffset(int)
     */
    int toOriginOffset(int offset) ;

    /*
     * @see org.eclipse.jface.text.IDocumentInformationMappingExtension#toExactOriginRegions(IRegion)
     */
    IRegion[] toExactOriginRegions(IRegion region) ;

    /*
     * @see org.eclipse.jface.text.IDocumentInformationMappingExtension#getImageLength()
     */
    int getImageLength();
}
