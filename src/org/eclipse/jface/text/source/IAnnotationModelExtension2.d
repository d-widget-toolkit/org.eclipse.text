/*******************************************************************************
 * Copyright (c) 2007 IBM Corporation and others.
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
module org.eclipse.jface.text.source.IAnnotationModelExtension2;
import org.eclipse.jface.text.source.IAnnotationMap;
import org.eclipse.jface.text.source.IAnnotationModelListenerExtension;
import org.eclipse.jface.text.source.AnnotationModelEvent;
import org.eclipse.jface.text.source.IAnnotationModel;
import org.eclipse.jface.text.source.AnnotationMap;
import org.eclipse.jface.text.source.IAnnotationModelExtension;
import org.eclipse.jface.text.source.AnnotationModel;
import org.eclipse.jface.text.source.Annotation;
import org.eclipse.jface.text.source.IAnnotationModelListener;



import java.lang.all;
import java.util.Iterator;
import java.util.Set;



/**
 * Extends {@link org.eclipse.jface.text.source.IAnnotationModel} with the
 * ability to retrieve a set of annotations within a given region.
 *
 * @since 3.4
 */
public interface IAnnotationModelExtension2 {

    /**
     * Returns an iterator over all annotations managed by this model that are
     * inside the given region.
     * 
     * @param offset the start position of the region, must be >= 0
     * @param length the length of the region, must be >= 0
     * @param canStartBefore if <code>true</code> then annotations are included
     *            which start before the region if they end at or after the region's start
     * @param canEndAfter if <code>true</code> then annotations are included
     *            which end after the region if they start at or before the region's end
     * @return all annotations inside the region managed by this model (element type: {@link Annotation})
     */
    Iterator getAnnotationIterator(int offset, int length, bool canStartBefore, bool canEndAfter);
}
