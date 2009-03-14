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
module org.eclipse.jface.text.projection.ProjectionDocumentManager;
import org.eclipse.jface.text.projection.ChildDocumentManager;
import org.eclipse.jface.text.projection.IMinimalMapping;
import org.eclipse.jface.text.projection.Segment;
import org.eclipse.jface.text.projection.ChildDocument;
import org.eclipse.jface.text.projection.ProjectionMapping;
import org.eclipse.jface.text.projection.FragmentUpdater;
import org.eclipse.jface.text.projection.SegmentUpdater;
import org.eclipse.jface.text.projection.ProjectionDocumentEvent;
import org.eclipse.jface.text.projection.ProjectionTextStore;
import org.eclipse.jface.text.projection.Fragment;
import org.eclipse.jface.text.projection.ProjectionDocument;



import java.lang.all;
import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;






import org.eclipse.jface.text.DocumentEvent;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IDocumentInformationMapping;
import org.eclipse.jface.text.IDocumentListener;
import org.eclipse.jface.text.ISlaveDocumentManager;
import org.eclipse.jface.text.ISlaveDocumentManagerExtension;


/**
 * A <code>ProjectionDocumentManager</code> is one particular implementation
 * of {@link org.eclipse.jface.text.ISlaveDocumentManager}. This manager
 * creates so called projection documents (see
 * {@link org.eclipse.jface.text.projection.ProjectionDocument}as slave
 * documents for given master documents.
 * <p>
 * A projection document represents a particular projection of the master
 * document and is accordingly adapted to changes of the master document. Vice
 * versa, the master document is accordingly adapted to changes of its slave
 * documents. The manager does not maintain any particular management structure
 * but utilizes mechanisms given by {@link org.eclipse.jface.text.IDocument}
 * such as position categories and position updaters.
 * <p>
 * Clients can instantiate this class. This class is not intended to be
 * subclassed.</p>
 *
 * @since 3.0
 * @noextend This class is not intended to be subclassed by clients.
 */
public class ProjectionDocumentManager : IDocumentListener, ISlaveDocumentManager, ISlaveDocumentManagerExtension {

    /** Registry for master documents and their projection documents. */
    private Map fProjectionRegistry;

    this(){
        fProjectionRegistry= new HashMap();
    }

    /**
     * Registers the given projection document for the given master document.
     *
     * @param master the master document
     * @param projection the projection document
     */
    private void add(IDocument master, ProjectionDocument projection) {
        List list= cast(List) fProjectionRegistry.get(cast(Object)master);
        if (list is null) {
            list= new ArrayList(1);
            fProjectionRegistry.put(cast(Object)master, cast(Object)list);
        }
        list.add(projection);
    }

    /**
     * Unregisters the given projection document from its master.
     *
     * @param master the master document
     * @param projection the projection document
     */
    private void remove(IDocument master, ProjectionDocument projection) {
        List list= cast(List) fProjectionRegistry.get(cast(Object)master);
        if (list !is null) {
            list.remove(projection);
            if (list.size() is 0)
                fProjectionRegistry.remove(cast(Object)master);
        }
    }

    /**
     * Returns whether the given document is a master document.
     *
     * @param master the document
     * @return <code>true</code> if the given document is a master document known to this manager
     */
    private bool hasProjection(IDocument master) {
        return ( null !is cast(List)fProjectionRegistry.get(cast(Object)master) );
    }

    /**
     * Returns an iterator enumerating all projection documents registered for the given document or
     * <code>null</code> if the document is not a known master document.
     *
     * @param master the document
     * @return an iterator for all registered projection documents or <code>null</code>
     */
    private Iterator getProjectionsIterator(IDocument master) {
        List list= cast(List) fProjectionRegistry.get(cast(Object)master);
        if (list !is null)
            return list.iterator();
        return null;
    }

    /**
     * Informs all projection documents of the master document that issued the given document event.
     *
     * @param about indicates whether the change is about to happen or happened already
     * @param masterEvent the document event which will be processed to inform the projection documents
     */
    protected void fireDocumentEvent(bool about, DocumentEvent masterEvent) {
        IDocument master= masterEvent.getDocument();
        Iterator e= getProjectionsIterator(master);
        if (e is null)
            return;

        while (e.hasNext()) {
            ProjectionDocument document= cast(ProjectionDocument) e.next();
            if (about)
                document.masterDocumentAboutToBeChanged(masterEvent);
            else
                document.masterDocumentChanged(masterEvent);
        }
    }

    /*
     * @see org.eclipse.jface.text.IDocumentListener#documentChanged(org.eclipse.jface.text.DocumentEvent)
     */
    public void documentChanged(DocumentEvent event) {
        fireDocumentEvent(false, event);
    }

    /*
     * @see org.eclipse.jface.text.IDocumentListener#documentAboutToBeChanged(org.eclipse.jface.text.DocumentEvent)
     */
    public void documentAboutToBeChanged(DocumentEvent event) {
        fireDocumentEvent(true, event);
    }

    /*
     * @see org.eclipse.jface.text.ISlaveDocumentManager#createMasterSlaveMapping(org.eclipse.jface.text.IDocument)
     */
    public IDocumentInformationMapping createMasterSlaveMapping(IDocument slave) {
        if ( cast(ProjectionDocument)slave ) {
            ProjectionDocument projectionDocument= cast(ProjectionDocument) slave;
            return projectionDocument.getDocumentInformationMapping();
        }
        return null;
    }

    /*
     * @see org.eclipse.jface.text.ISlaveDocumentManager#createSlaveDocument(org.eclipse.jface.text.IDocument)
     */
    public IDocument createSlaveDocument(IDocument master) {
        if (!hasProjection(master))
            master.addDocumentListener(this);
        ProjectionDocument slave= createProjectionDocument(master);
        add(master, slave);
        return slave;
    }

    /**
     * Factory method for projection documents.
     *
     * @param master the master document
     * @return the newly created projection document
     */
    protected ProjectionDocument createProjectionDocument(IDocument master) {
        return new ProjectionDocument(master);
    }

    /*
     * @see org.eclipse.jface.text.ISlaveDocumentManager#freeSlaveDocument(org.eclipse.jface.text.IDocument)
     */
    public void freeSlaveDocument(IDocument slave) {
        if ( cast(ProjectionDocument)slave ) {
            ProjectionDocument projectionDocument= cast(ProjectionDocument) slave;
            IDocument master= projectionDocument.getMasterDocument();
            remove(master, projectionDocument);
            projectionDocument.dispose();
            if (!hasProjection(master))
                master.removeDocumentListener(this);
        }
    }

    /*
     * @see org.eclipse.jface.text.ISlaveDocumentManager#getMasterDocument(org.eclipse.jface.text.IDocument)
     */
    public IDocument getMasterDocument(IDocument slave) {
        if ( cast(ProjectionDocument)slave )
            return (cast(ProjectionDocument) slave).getMasterDocument();
        return null;
    }

    /*
     * @see org.eclipse.jface.text.ISlaveDocumentManager#isSlaveDocument(org.eclipse.jface.text.IDocument)
     */
    public bool isSlaveDocument(IDocument document) {
        return ( null !is cast(ProjectionDocument)document );
    }

    /*
     * @see org.eclipse.jface.text.ISlaveDocumentManager#setAutoExpandMode(org.eclipse.jface.text.IDocument, bool)
     */
    public void setAutoExpandMode(IDocument slave, bool autoExpanding) {
        if ( cast(ProjectionDocument)slave )
            (cast(ProjectionDocument) slave).setAutoExpandMode(autoExpanding);
    }

    /*
     * @see org.eclipse.jface.text.ISlaveDocumentManagerExtension#getSlaveDocuments(org.eclipse.jface.text.IDocument)
     */
    public IDocument[] getSlaveDocuments(IDocument master) {
        List list= cast(List) fProjectionRegistry.get(cast(Object)master);
        if (list !is null) {
            return arraycast!(IDocument)(list.toArray());
        }
        return null;
    }
}
