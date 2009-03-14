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
module org.eclipse.jface.text.source.Annotation;
import org.eclipse.jface.text.source.IAnnotationMap;
import org.eclipse.jface.text.source.AnnotationModelEvent;
import org.eclipse.jface.text.source.IAnnotationModelExtension2;
import org.eclipse.jface.text.source.IAnnotationModelListenerExtension;
import org.eclipse.jface.text.source.AnnotationMap;
import org.eclipse.jface.text.source.IAnnotationModel;
import org.eclipse.jface.text.source.IAnnotationModelExtension;
import org.eclipse.jface.text.source.AnnotationModel;
import org.eclipse.jface.text.source.IAnnotationModelListener;



import java.lang.all;
import java.util.Set;


/**
 * Annotation managed by an
 * {@link org.eclipse.jface.text.source.IAnnotationModel}.
 * <p>
 * Annotations are typed, can have an associated text and can be marked as persistent and
 * deleted. Annotations which are not explicitly initialized with an annotation
 * type are of type <code>"org.eclipse.text.annotation.unknown"</code>.
 */
public class Annotation {

    /**
     * Constant for unknown annotation types.<p>
     * Value: <code>"org.eclipse.text.annotation.unknown"</code>
     * @since 3.0
     */
    public const static String TYPE_UNKNOWN= "org.eclipse.text.annotation.unknown";  //$NON-NLS-1$


    /**
     * The type of this annotation.
     * @since 3.0
     */
    private String fType;
    /**
     * Indicates whether this annotation is persistent or not.
     * @since 3.0
     */
    private bool fIsPersistent= false;
    /**
     * Indicates whether this annotation is marked as deleted or not.
     * @since 3.0
     */
    private bool fMarkedAsDeleted= false;
    /**
     * The text associated with this annotation.
     * @since 3.0
     */
    private String fText;


    /**
     * Creates a new annotation that is not persistent and type less.
     */
    protected this() {
        this(null, false, null);
    }

    /**
     * Creates a new annotation with the given properties.
     *
     * @param type the unique name of this annotation type
     * @param isPersistent <code>true</code> if this annotation is
     *            persistent, <code>false</code> otherwise
     * @param text the text associated with this annotation
     * @since 3.0
     */
    public this(String type, bool isPersistent, String text) {
        fType= type;
        fIsPersistent= isPersistent;
        fText= text;
    }

    /**
     * Creates a new annotation with the given persistence state.
     *
     * @param isPersistent <code>true</code> if persistent, <code>false</code> otherwise
     * @since 3.0
     */
    public this(bool isPersistent) {
        this(null, isPersistent, null);
    }

    /**
     * Returns whether this annotation is persistent.
     *
     * @return <code>true</code> if this annotation is persistent, <code>false</code>
     *         otherwise
     * @since 3.0
     */
    public bool isPersistent() {
        return fIsPersistent;
    }

    /**
     * Sets the type of this annotation.
     *
     * @param type the annotation type
     * @since 3.0
     */
    public void setType(String type) {
        fType= type;
    }

    /**
     * Returns the type of the annotation.
     *
     * @return the type of the annotation
     * @since 3.0
     */
    public String getType() {
        return fType is null ? TYPE_UNKNOWN : fType;
    }

    /**
     * Marks this annotation deleted according to the value of the
     * <code>deleted</code> parameter.
     *
     * @param deleted <code>true</code> if annotation should be marked as deleted
     * @since 3.0
     */
    public void markDeleted(bool deleted) {
        fMarkedAsDeleted= deleted;
    }

    /**
     * Returns whether this annotation is marked as deleted.
     *
     * @return <code>true</code> if annotation is marked as deleted, <code>false</code>
     *         otherwise
     * @since 3.0
     */
    public bool isMarkedDeleted() {
        return fMarkedAsDeleted;
    }

    /**
     * Sets the text associated with this annotation.
     *
     * @param text the text associated with this annotation
     * @since 3.0
     */
    public void setText(String text) {
        fText= text;
    }

    /**
     * Returns the text associated with this annotation.
     *
     * @return the text associated with this annotation or <code>null</code>
     * @since 3.0
     */
    public String getText() {
        return fText;
    }
}
