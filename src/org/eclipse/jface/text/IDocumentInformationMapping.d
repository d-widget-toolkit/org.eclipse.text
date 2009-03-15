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
module org.eclipse.jface.text.IDocumentInformationMapping;
import org.eclipse.jface.text.IRepairableDocument;
import org.eclipse.jface.text.AbstractDocument;
import org.eclipse.jface.text.IDocumentPartitionerExtension3;
import org.eclipse.jface.text.ConfigurableLineTracker;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.TypedRegion;
import org.eclipse.jface.text.IDocumentExtension2;
import org.eclipse.jface.text.TypedPosition;
import org.eclipse.jface.text.RewriteSessionEditProcessor;
import org.eclipse.jface.text.SlaveDocumentEvent;
import org.eclipse.jface.text.IDocumentExtension3;
import org.eclipse.jface.text.IDocumentListener;
import org.eclipse.jface.text.ISynchronizable;
import org.eclipse.jface.text.DocumentEvent;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.IRepairableDocumentExtension;
import org.eclipse.jface.text.DocumentRewriteSessionType;
import org.eclipse.jface.text.Region;
import org.eclipse.jface.text.IDocumentExtension4;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.TextMessages;
import org.eclipse.jface.text.IDocumentPartitioningListenerExtension2;
import org.eclipse.jface.text.IDocumentInformationMappingExtension;
import org.eclipse.jface.text.IDocumentPartitioningListenerExtension;
import org.eclipse.jface.text.ITextStore;
import org.eclipse.jface.text.IDocumentPartitionerExtension;
import org.eclipse.jface.text.DocumentRewriteSession;
import org.eclipse.jface.text.IPositionUpdater;
import org.eclipse.jface.text.ISlaveDocumentManagerExtension;
import org.eclipse.jface.text.ILineTracker;
import org.eclipse.jface.text.ListLineTracker;
import org.eclipse.jface.text.IDocumentRewriteSessionListener;
import org.eclipse.jface.text.AbstractLineTracker;
import org.eclipse.jface.text.DefaultLineTracker;
import org.eclipse.jface.text.BadPositionCategoryException;
import org.eclipse.jface.text.BadPartitioningException;
import org.eclipse.jface.text.SequentialRewriteTextStore;
import org.eclipse.jface.text.IDocumentInformationMappingExtension2;
import org.eclipse.jface.text.DocumentPartitioningChangedEvent;
import org.eclipse.jface.text.FindReplaceDocumentAdapter;
import org.eclipse.jface.text.TextUtilities;
import org.eclipse.jface.text.ISlaveDocumentManager;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ILineTrackerExtension;
import org.eclipse.jface.text.IDocumentPartitioner;
import org.eclipse.jface.text.GapTextStore;
import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.IDocumentExtension;
import org.eclipse.jface.text.IDocumentPartitioningListener;
import org.eclipse.jface.text.CopyOnWriteTextStore;
import org.eclipse.jface.text.DefaultPositionUpdater;
import org.eclipse.jface.text.Line;
import org.eclipse.jface.text.DocumentRewriteSessionEvent;
import org.eclipse.jface.text.IDocumentPartitionerExtension2;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.TreeLineTracker;



import java.lang.all;
import java.util.Set;


/**
 * A <code>IDocumentInformationMapping</code>  represents a mapping between the coordinates of two
 * <code>IDocument</code> objects: the original and the image. The document information mapping
 * can translate document information such as line numbers or character ranges given for the original into
 * the corresponding information of the image and vice versa.
 *
 * In order to provided backward compatibility for clients of <code>IDocumentInformationMapping</code>, extension
 * interfaces are used to provide a means of evolution. The following extension interfaces
 * exist:
 * <ul>
 * <li> {@link org.eclipse.jface.text.IDocumentInformationMappingExtension} since version 3.0 extending the
 *      degree of detail of the mapping information.</li>
 * <li> {@link org.eclipse.jface.text.IDocumentInformationMappingExtension2} since version 3.1, adding lenient
 *      image region computation.</li>
 * </ul>
 *
 * @since 2.1
 */
public interface IDocumentInformationMapping {

    /**
     * Returns the minimal region of the original document that completely comprises all of the image document
     * or <code>null</code> if there is no such region.
     *
     * @return the minimal region of the original document comprising the image document or <code>null</code>
     */
    IRegion getCoverage();

    /**
     * Returns the offset in the original document that corresponds to the given offset in the image document
     * or <code>-1</code> if there is no such offset
     *
     * @param imageOffset the offset in the image document
     * @return the corresponding offset in the original document or <code>-1</code>
     * @throws BadLocationException if <code>imageOffset</code> is not a valid offset in the image document
     */
    int toOriginOffset(int imageOffset) ;

    /**
     * Returns the minimal region of the original document that completely comprises the given region of the
     * image document or <code>null</code> if there is no such region.
     *
     * @param imageRegion the region of the image document
     * @return the minimal region of the original document comprising the given region of the image document or <code>null</code>
     * @throws BadLocationException if <code>imageRegion</code> is not a valid region of the image document
     */
    IRegion toOriginRegion(IRegion imageRegion) ;

    /**
     * Returns the range of lines of the original document that corresponds to the given line of the image document or
     * <code>null</code> if there are no such lines.
     *
     * @param imageLine the line of the image document
     * @return the corresponding lines of the original document or <code>null</code>
     * @throws BadLocationException if <code>imageLine</code> is not a valid line number in the image document
     */
    IRegion toOriginLines(int imageLine) ;

    /**
     * Returns the line of the original document that corresponds to the given line of the image document or
     * <code>-1</code> if there is no such line.
     *
     * @param imageLine the line of the image document
     * @return the corresponding line of the original document or <code>-1</code>
     * @throws BadLocationException if <code>imageLine</code> is not a valid line number in the image document
     */
    int toOriginLine(int imageLine) ;



    /**
     * Returns the offset in the image document that corresponds to the given offset in the original document
     * or <code>-1</code> if there is no such offset
     *
     * @param originOffset the offset in the original document
     * @return the corresponding offset in the image document or <code>-1</code>
     * @throws BadLocationException if <code>originOffset</code> is not a valid offset in the original document
     */
    int toImageOffset(int originOffset) ;

    /**
     * Returns the minimal region of the image document that completely comprises the given region of the
     * original document or <code>null</code> if there is no such region.
     *
     * @param originRegion the region of the original document
     * @return the minimal region of the image document comprising the given region of the original document or <code>null</code>
     * @throws BadLocationException if <code>originRegion</code> is not a valid region of the original document
     */
    IRegion toImageRegion(IRegion originRegion) ;

    /**
     * Returns the line of the image document that corresponds to the given line of the original document or
     * <code>-1</code> if there is no such line.
     *
     * @param originLine the line of the original document
     * @return the corresponding line of the image document or <code>-1</code>
     * @throws BadLocationException if <code>originLine</code> is not a valid line number in the original document
     */
    int toImageLine(int originLine) ;

    /**
     * Returns the line of the image document whose corresponding line in the original document
     * is closest to the given line in the original document.
     *
     * @param originLine the line in the original document
     * @return the line in the image document that corresponds best to the given line in the original document
     * @throws BadLocationException if <code>originLine</code>is not a valid line in the original document
     */
    int toClosestImageLine(int originLine) ;
}
