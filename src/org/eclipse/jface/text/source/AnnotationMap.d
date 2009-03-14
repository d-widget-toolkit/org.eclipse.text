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
module org.eclipse.jface.text.source.AnnotationMap;

import org.eclipse.jface.text.source.ISharedTextColors; // packageimport
import org.eclipse.jface.text.source.ILineRange; // packageimport
import org.eclipse.jface.text.source.IAnnotationPresentation; // packageimport
import org.eclipse.jface.text.source.IVerticalRulerInfoExtension; // packageimport
import org.eclipse.jface.text.source.ICharacterPairMatcher; // packageimport
import org.eclipse.jface.text.source.TextInvocationContext; // packageimport
import org.eclipse.jface.text.source.LineChangeHover; // packageimport
import org.eclipse.jface.text.source.IChangeRulerColumn; // packageimport
import org.eclipse.jface.text.source.IAnnotationMap; // packageimport
import org.eclipse.jface.text.source.IAnnotationModelListenerExtension; // packageimport
import org.eclipse.jface.text.source.ISourceViewerExtension2; // packageimport
import org.eclipse.jface.text.source.IAnnotationHover; // packageimport
import org.eclipse.jface.text.source.ContentAssistantFacade; // packageimport
import org.eclipse.jface.text.source.IAnnotationAccess; // packageimport
import org.eclipse.jface.text.source.IVerticalRulerExtension; // packageimport
import org.eclipse.jface.text.source.IVerticalRulerColumn; // packageimport
import org.eclipse.jface.text.source.LineNumberRulerColumn; // packageimport
import org.eclipse.jface.text.source.MatchingCharacterPainter; // packageimport
import org.eclipse.jface.text.source.IAnnotationModelExtension; // packageimport
import org.eclipse.jface.text.source.ILineDifferExtension; // packageimport
import org.eclipse.jface.text.source.DefaultCharacterPairMatcher; // packageimport
import org.eclipse.jface.text.source.LineNumberChangeRulerColumn; // packageimport
import org.eclipse.jface.text.source.IAnnotationAccessExtension; // packageimport
import org.eclipse.jface.text.source.ISourceViewer; // packageimport
import org.eclipse.jface.text.source.AnnotationModel; // packageimport
import org.eclipse.jface.text.source.ILineDifferExtension2; // packageimport
import org.eclipse.jface.text.source.IAnnotationModelListener; // packageimport
import org.eclipse.jface.text.source.IVerticalRuler; // packageimport
import org.eclipse.jface.text.source.DefaultAnnotationHover; // packageimport
import org.eclipse.jface.text.source.SourceViewer; // packageimport
import org.eclipse.jface.text.source.SourceViewerConfiguration; // packageimport
import org.eclipse.jface.text.source.AnnotationBarHoverManager; // packageimport
import org.eclipse.jface.text.source.CompositeRuler; // packageimport
import org.eclipse.jface.text.source.ImageUtilities; // packageimport
import org.eclipse.jface.text.source.VisualAnnotationModel; // packageimport
import org.eclipse.jface.text.source.IAnnotationModel; // packageimport
import org.eclipse.jface.text.source.ISourceViewerExtension3; // packageimport
import org.eclipse.jface.text.source.ILineDiffInfo; // packageimport
import org.eclipse.jface.text.source.VerticalRulerEvent; // packageimport
import org.eclipse.jface.text.source.ChangeRulerColumn; // packageimport
import org.eclipse.jface.text.source.ILineDiffer; // packageimport
import org.eclipse.jface.text.source.AnnotationModelEvent; // packageimport
import org.eclipse.jface.text.source.AnnotationColumn; // packageimport
import org.eclipse.jface.text.source.AnnotationRulerColumn; // packageimport
import org.eclipse.jface.text.source.IAnnotationHoverExtension; // packageimport
import org.eclipse.jface.text.source.AbstractRulerColumn; // packageimport
import org.eclipse.jface.text.source.ISourceViewerExtension; // packageimport
import org.eclipse.jface.text.source.IVerticalRulerInfo; // packageimport
import org.eclipse.jface.text.source.IAnnotationModelExtension2; // packageimport
import org.eclipse.jface.text.source.LineRange; // packageimport
import org.eclipse.jface.text.source.IAnnotationAccessExtension2; // packageimport
import org.eclipse.jface.text.source.VerticalRuler; // packageimport
import org.eclipse.jface.text.source.JFaceTextMessages; // packageimport
import org.eclipse.jface.text.source.IOverviewRuler; // packageimport
import org.eclipse.jface.text.source.Annotation; // packageimport
import org.eclipse.jface.text.source.IVerticalRulerListener; // packageimport
import org.eclipse.jface.text.source.ISourceViewerExtension4; // packageimport
import org.eclipse.jface.text.source.AnnotationPainter; // packageimport
import org.eclipse.jface.text.source.IAnnotationHoverExtension2; // packageimport
import org.eclipse.jface.text.source.OverviewRuler; // packageimport
import org.eclipse.jface.text.source.OverviewRulerHoverManager; // packageimport


import java.lang.all;
import java.util.Collection;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;









/**
 * Internal implementation of {@link org.eclipse.jface.text.source.IAnnotationMap}.
 *
 * @since 3.0
 */
class AnnotationMap : IAnnotationMap {

    /**
     * The lock object used to synchronize the operations explicitly defined by
     * <code>IAnnotationMap</code>
     */
    private Object fLockObject;
    /**
     * The internal lock object used if <code>fLockObject</code> is <code>null</code>.
     * @since 3.2
     */
    private const Object fInternalLockObject;

    /** The map holding the annotations */
    private Map fInternalMap;

    /**
     * Creates a new annotation map with the given capacity.
     *
     * @param capacity the capacity
     */
    public this(int capacity) {
        fInternalLockObject= new Object();
        fInternalMap= new HashMap(capacity);
    }

    /*
     * @see org.eclipse.jface.text.source.ISynchronizable#setLockObject(java.lang.Object)
     */
    public synchronized void setLockObject(Object lockObject) {
        fLockObject= lockObject;
    }

    /*
     * @see org.eclipse.jface.text.source.ISynchronizable#getLockObject()
     */
    public synchronized Object getLockObject() {
        if (fLockObject is null)
            return fInternalLockObject;
        return fLockObject;
    }

    /*
     * @see org.eclipse.jface.text.source.IAnnotationMap#valuesIterator()
     */
    public Iterator valuesIterator() {
        synchronized (getLockObject()) {
            return (new ArrayList(fInternalMap.values())).iterator();
        }
    }

    /*
     * @see org.eclipse.jface.text.source.IAnnotationMap#keySetIterator()
     */
    public Iterator keySetIterator() {
        synchronized (getLockObject()) {
            return (new ArrayList(fInternalMap.keySet())).iterator();
        }
    }

    /*
     * @see java.util.Map#containsKey(java.lang.Object)
     */
    public bool containsKey(Object annotation) {
        synchronized (getLockObject()) {
            return fInternalMap.containsKey(annotation);
        }
    }

    /*
     * @see java.util.Map#put(java.lang.Object, java.lang.Object)
     */
    public Object put(Object annotation, Object position) {
        synchronized (getLockObject()) {
            return fInternalMap.put(annotation, position);
        }
    }

    /*
     * @see java.util.Map#get(java.lang.Object)
     */
    public Object get(Object annotation) {
        synchronized (getLockObject()) {
            return fInternalMap.get(annotation);
        }
    }

    /*
     * @see java.util.Map#clear()
     */
    public void clear() {
        synchronized (getLockObject()) {
            fInternalMap.clear();
        }
    }

    /*
     * @see java.util.Map#remove(java.lang.Object)
     */
    public Object remove(Object annotation) {
        synchronized (getLockObject()) {
            return fInternalMap.remove(annotation);
        }
    }

    /*
     * @see java.util.Map#size()
     */
    public int size() {
        synchronized (getLockObject()) {
            return fInternalMap.size();
        }
    }

    /*
     * @see java.util.Map#isEmpty()
     */
    public bool isEmpty() {
        synchronized (getLockObject()) {
            return fInternalMap.isEmpty();
        }
    }

    /*
     * @see java.util.Map#containsValue(java.lang.Object)
     */
    public bool containsValue(Object value) {
        synchronized(getLockObject()) {
            return fInternalMap.containsValue(value);
        }
    }

    /*
     * @see java.util.Map#putAll(java.util.Map)
     */
    public void putAll(Map map) {
        synchronized (getLockObject()) {
            fInternalMap.putAll(map);
        }
    }

    /*
     * @see IAnnotationMap#entrySet()
     */
    public Set entrySet() {
        synchronized (getLockObject()) {
            return fInternalMap.entrySet();
        }
    }

    /*
     * @see IAnnotationMap#keySet()
     */
    public Set keySet() {
        synchronized (getLockObject()) {
            return fInternalMap.keySet();
        }
    }

    /*
     * @see IAnnotationMap#values()
     */
    public Collection values() {
        synchronized (getLockObject()) {
            return fInternalMap.values();
        }
    }

    /// SWT extension of Collection interfaces

    public bool containsKey(String key) {
        return containsKey(stringcast(key));
    }
    public Object get(String key) {
        return get(stringcast(key));
    }
    public Object put(String key, String value) {
        return put(stringcast(key), stringcast(value));
    }
    public Object put(Object key, String value) {
        return put(key, stringcast(value));
    }
    public Object put(String key, Object value) {
        return put(stringcast(key), value);
    }
    public Object remove(String key) {
        return remove(stringcast(key));
    }
    public int opApply (int delegate(ref Object value) dg){
        implMissing(__FILE__,__LINE__);
        return 0;
    }
    public int opApply (int delegate(ref Object key, ref Object value) dg){
        implMissing(__FILE__,__LINE__);
        return 0;
    }

}
