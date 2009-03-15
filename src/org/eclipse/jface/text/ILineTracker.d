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
module org.eclipse.jface.text.ILineTracker;
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
import org.eclipse.jface.text.ListLineTracker;
import org.eclipse.jface.text.IDocumentInformationMapping;
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
 * A line tracker maps character positions to line numbers and vice versa.
 * Initially the line tracker is informed about its underlying text in order to
 * initialize the mapping information. After that, the line tracker is informed
 * about all changes of the underlying text allowing for incremental updates of
 * the mapping information. It is the client's responsibility to actively inform
 * the line tacker about text changes. For example, when using a line tracker in
 * combination with a document the document controls the line tracker.
 * <p>
 * In order to provide backward compatibility for clients of <code>ILineTracker</code>, extension
 * interfaces are used to provide a means of evolution. The following extension interfaces
 * exist:
 * <ul>
 * <li> {@link org.eclipse.jface.text.ILineTrackerExtension} since version 3.1 introducing the concept
 *      of rewrite sessions.</li>
 * </ul>
 * <p>
 * Clients may implement this interface or use the standard implementation
 * </p>
 * {@link org.eclipse.jface.text.DefaultLineTracker}or
 * {@link org.eclipse.jface.text.ConfigurableLineTracker}.
 */
public interface ILineTracker {

    /**
     * Returns the strings this tracker considers as legal line delimiters.
     *
     * @return the legal line delimiters
     */
    String[] getLegalLineDelimiters();

    /**
     * Returns the line delimiter of the specified line. Returns <code>null</code> if the
     * line is not closed with a line delimiter.
     *
     * @param line the line whose line delimiter is queried
     * @return the line's delimiter or <code>null</code> if line does not have a delimiter
     * @exception BadLocationException if the line number is invalid in this tracker's line structure
     */
    String getLineDelimiter(int line) ;

    /**
     * Computes the number of lines in the given text.
     *
     * @param text the text whose number of lines should be computed
     * @return the number of lines in the given text
     */
    int computeNumberOfLines(String text);

    /**
     * Returns the number of lines.
     *
     * @return the number of lines in this tracker's line structure
     */
    int getNumberOfLines();

    /**
     * Returns the number of lines which are occupied by a given text range.
     *
     * @param offset the offset of the specified text range
     * @param length the length of the specified text range
     * @return the number of lines occupied by the specified range
     * @exception BadLocationException if specified range is unknown to this tracker
     */
    int getNumberOfLines(int offset, int length) ;

    /**
     * Returns the position of the first character of the specified line.
     *
     * @param line the line of interest
     * @return offset of the first character of the line
     * @exception BadLocationException if the line is unknown to this tracker
     */
    int getLineOffset(int line) ;

    /**
     * Returns length of the specified line including the line's delimiter.
     *
     * @param line the line of interest
     * @return the length of the line
     * @exception BadLocationException if line is unknown to this tracker
     */
    int getLineLength(int line) ;

    /**
     * Returns the line number the character at the given offset belongs to.
     *
     * @param offset the offset whose line number to be determined
     * @return the number of the line the offset is on
     * @exception BadLocationException if the offset is invalid in this tracker
     */
    int getLineNumberOfOffset(int offset) ;

    /**
     * Returns a line description of the line at the given offset.
     * The description contains the start offset and the length of the line
     * excluding the line's delimiter.
     *
     * @param offset the offset whose line should be described
     * @return a region describing the line
     * @exception BadLocationException if offset is invalid in this tracker
     */
    IRegion getLineInformationOfOffset(int offset) ;

    /**
     * Returns a line description of the given line. The description
     * contains the start offset and the length of the line excluding the line's
     * delimiter.
     *
     * @param line the line that should be described
     * @return a region describing the line
     * @exception BadLocationException if line is unknown to this tracker
     */
    IRegion getLineInformation(int line) ;

    /**
     * Informs the line tracker about the specified change in the tracked text.
     *
     * @param offset the offset of the replaced text
     * @param length the length of the replaced text
     * @param text the substitution text
     * @exception BadLocationException if specified range is unknown to this tracker
     */
    void replace(int offset, int length, String text) ;

    /**
     * Sets the tracked text to the specified text.
     *
     * @param text the new tracked text
     */
    void set(String text);
}
