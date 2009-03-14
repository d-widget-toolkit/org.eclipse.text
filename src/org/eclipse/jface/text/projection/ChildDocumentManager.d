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
import org.eclipse.jface.text.projection.IMinimalMapping;
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
