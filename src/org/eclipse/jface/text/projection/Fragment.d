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
module org.eclipse.jface.text.projection.Fragment;

import org.eclipse.jface.text.projection.ProjectionMapping; // packageimport
import org.eclipse.jface.text.projection.ChildDocumentManager; // packageimport
import org.eclipse.jface.text.projection.SegmentUpdater; // packageimport
import org.eclipse.jface.text.projection.Segment; // packageimport
import org.eclipse.jface.text.projection.ProjectionDocument; // packageimport
import org.eclipse.jface.text.projection.FragmentUpdater; // packageimport
import org.eclipse.jface.text.projection.ProjectionDocumentEvent; // packageimport
import org.eclipse.jface.text.projection.ChildDocument; // packageimport
import org.eclipse.jface.text.projection.IMinimalMapping; // packageimport
import org.eclipse.jface.text.projection.ProjectionTextStore; // packageimport
import org.eclipse.jface.text.projection.ProjectionDocumentManager; // packageimport


import java.lang.all;
import java.util.Set;

import org.eclipse.jface.text.Position;


/**
 * Internal class. Do not use. Only public for testing purposes.
 * <p>
 * A fragment is a range of the master document that has an image, the so called
 * segment, in a projection document.</p>
 *
 * @since 3.0
 * @noinstantiate This class is not intended to be instantiated by clients.
 * @noextend This class is not intended to be subclassed by clients.
 */
public class Fragment : Position {

    /**
     * The corresponding segment of this fragment.
     */
    public Segment segment;

    /**
     * Creates a new fragment covering the given range.
     *
     * @param offset the offset of the fragment
     * @param length the length of the fragment
     */
    public this(int offset, int length) {
        super(offset, length);
    }
}
