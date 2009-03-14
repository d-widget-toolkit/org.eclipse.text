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
module org.eclipse.jface.text.source.IAnnotationModelListenerExtension;
import org.eclipse.jface.text.source.IAnnotationMap;
import org.eclipse.jface.text.source.AnnotationModelEvent;
import org.eclipse.jface.text.source.IAnnotationModelExtension2;
import org.eclipse.jface.text.source.IAnnotationModel;
import org.eclipse.jface.text.source.AnnotationMap;
import org.eclipse.jface.text.source.IAnnotationModelExtension;
import org.eclipse.jface.text.source.AnnotationModel;
import org.eclipse.jface.text.source.Annotation;
import org.eclipse.jface.text.source.IAnnotationModelListener;



import java.lang.all;


/**
 * Extension interface for {@link IAnnotationModelListener}. Introduces a
 * notification mechanism that notifies the user by means of <code>AnnotationModelEvent</code>s.
 * Thus, more detailed information can be sent to the listener. This mechanism replaces the original notification
 * mechanism of <code>IAnnotationModelListener</code>.
 *
 * @since 2.0
 */
public interface IAnnotationModelListenerExtension {

    /**
     * Called if a model change occurred on the given model.
     *
     * @param event the event to be sent out
     */
    void modelChanged(AnnotationModelEvent event);
}
