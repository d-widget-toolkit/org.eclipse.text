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
module org.eclipse.jface.text.projection.ChildDocumentManager;

import org.eclipse.jface.text.projection.ProjectionMapping; // packageimport
import org.eclipse.jface.text.projection.SegmentUpdater; // packageimport
import org.eclipse.jface.text.projection.Segment; // packageimport
import org.eclipse.jface.text.projection.ProjectionDocument; // packageimport
import org.eclipse.jface.text.projection.FragmentUpdater; // packageimport
import org.eclipse.jface.text.projection.ProjectionDocumentEvent; // packageimport
import org.eclipse.jface.text.projection.ChildDocument; // packageimport
import org.eclipse.jface.text.projection.IMinimalMapping; // packageimport
import org.eclipse.jface.text.projection.Fragment; // packageimport
import org.eclipse.jface.text.projection.ProjectionTextStore; // packageimport
import org.eclipse.jface.text.projection.ProjectionDocumentManager; // packageimport


import java.lang.all;

import org.eclipse.jface.text.IDocument;


/**
 * Implementation of a child document manager based on
 * {@link org.eclipse.jface.text.projection.ProjectionDocumentManager}. This
 * class exists for compatibility reasons.
 * <p>
 * Internal class. This class is not intended to be used by clients outside
 * the Platform Text framework.</p>
 *
 * @since 3.0
 * @noinstantiate This class is not intended to be instantiated by clients.
 * @noextend This class is not intended to be subclassed by clients.
 */
public class ChildDocumentManager : ProjectionDocumentManager {

    /*
     * @see org.eclipse.jface.text.projection.ProjectionDocumentManager#createProjectionDocument(org.eclipse.jface.text.IDocument)
     */
    protected ProjectionDocument createProjectionDocument(IDocument master) {
        return new ChildDocument(master);
    }
}
