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
module org.eclipse.jface.text.ListLineTracker;
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
import java.util.List;
import java.util.ArrayList;
import java.util.Set;

import org.eclipse.jface.text.AbstractLineTracker;

/**
 * Abstract, read-only implementation of <code>ILineTracker</code>. It lets the definition of
 * line delimiters to subclasses. Assuming that '\n' is the only line delimiter, this abstract
 * implementation defines the following line scheme:
 * <ul>
 * <li> "" -> [0,0]
 * <li> "a" -> [0,1]
 * <li> "\n" -> [0,1], [1,0]
 * <li> "a\n" -> [0,2], [2,0]
 * <li> "a\nb" -> [0,2], [2,1]
 * <li> "a\nbc\n" -> [0,2], [2,3], [5,0]
 * </ul>
 * This class must be subclassed.
 *
 * @since 3.2
 */
abstract class ListLineTracker : ILineTracker {

    /** The line information */
    private const List fLines;
    /** The length of the tracked text */
    private int fTextLength;

    /**
     * Creates a new line tracker.
     */
    protected this() {
        fLines= new ArrayList();
    }

    /**
     * Binary search for the line at a given offset.
     *
     * @param offset the offset whose line should be found
     * @return the line of the offset
     */
    private int findLine(int offset) {

        if (fLines.size() is 0)
            return -1;

        int left= 0;
        int right= fLines.size() - 1;
        int mid= 0;
        Line line= null;

        while (left < right) {

            mid= (left + right) / 2;

            line= cast(Line) fLines.get(mid);
            if (offset < line.offset) {
                if (left is mid)
                    right= left;
                else
                    right= mid - 1;
            } else if (offset > line.offset) {
                if (right is mid)
                    left= right;
                else
                    left= mid + 1;
            } else if (offset is line.offset) {
                left= right= mid;
            }
        }

        line= cast(Line) fLines.get(left);
        if (line.offset > offset)
            --left;
        return left;
    }

    /**
     * Returns the number of lines covered by the specified text range.
     *
     * @param startLine the line where the text range starts
     * @param offset the start offset of the text range
     * @param length the length of the text range
     * @return the number of lines covered by this text range
     * @exception BadLocationException if range is undefined in this tracker
     */
    private int getNumberOfLines(int startLine, int offset, int length)  {

        if (length is 0)
            return 1;

        int target= offset + length;

        Line l= cast(Line) fLines.get(startLine);

        if (l.delimiter is null)
            return 1;

        if (l.offset + l.length > target)
            return 1;

        if (l.offset + l.length is target)
            return 2;

        return getLineNumberOfOffset(target) - startLine + 1;
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineLength(int)
     */
    public final int getLineLength(int line)  {
        int lines= fLines.size();

        if (line < 0 || line > lines)
            throw new BadLocationException();

        if (lines is 0 || lines is line)
            return 0;

        Line l= cast(Line) fLines.get(line);
        return l.length;
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineNumberOfOffset(int)
     */
    public final int getLineNumberOfOffset(int position)  {
        if (position < 0 || position > fTextLength)
            throw new BadLocationException();

        if (position is fTextLength) {

            int lastLine= fLines.size() - 1;
            if (lastLine < 0)
                return 0;

            Line l= cast(Line) fLines.get(lastLine);
            return (l.delimiter !is null ? lastLine + 1 : lastLine);
        }

        return findLine(position);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineInformationOfOffset(int)
     */
    public final IRegion getLineInformationOfOffset(int position)  {
        if (position > fTextLength)
            throw new BadLocationException();

        if (position is fTextLength) {
            int size= fLines.size();
            if (size is 0)
                return new Region(0, 0);
            Line l= cast(Line) fLines.get(size - 1);
            return (l.delimiter !is null ? new Line(fTextLength, 0) : new Line(fTextLength - l.length, l.length));
        }

        return getLineInformation(findLine(position));
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineInformation(int)
     */
    public final IRegion getLineInformation(int line)  {
        int lines= fLines.size();

        if (line < 0 || line > lines)
            throw new BadLocationException();

        if (lines is 0)
            return new Line(0, 0);

        if (line is lines) {
            Line l= cast(Line) fLines.get(line - 1);
            return new Line(l.offset + l.length, 0);
        }

        Line l= cast(Line) fLines.get(line);
        return (l.delimiter !is null ? new Line(l.offset, l.length - l.delimiter.length()) : l);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineOffset(int)
     */
    public final int getLineOffset(int line)  {
        int lines= fLines.size();

        if (line < 0 || line > lines)
            throw new BadLocationException();

        if (lines is 0)
            return 0;

        if (line is lines) {
            Line l= cast(Line) fLines.get(line - 1);
            if (l.delimiter !is null)
                return l.offset + l.length;
            throw new BadLocationException();
        }

        Line l= cast(Line) fLines.get(line);
        return l.offset;
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getNumberOfLines()
     */
    public final int getNumberOfLines() {
        int lines= fLines.size();

        if (lines is 0)
            return 1;

        Line l= cast(Line) fLines.get(lines - 1);
        return (l.delimiter !is null ? lines + 1 : lines);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getNumberOfLines(int, int)
     */
    public final int getNumberOfLines(int position, int length)  {

        if (position < 0 || position + length > fTextLength)
            throw new BadLocationException();

        if (length is 0) // optimization
            return 1;

        return getNumberOfLines(getLineNumberOfOffset(position), position, length);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#computeNumberOfLines(java.lang.String)
     */
    public final int computeNumberOfLines(String text) {
        int count= 0;
        int start= 0;
        AbstractLineTracker_DelimiterInfo delimiterInfo= nextDelimiterInfo(text, start);
        while (delimiterInfo !is null && delimiterInfo.delimiterIndex > -1) {
            ++count;
            start= delimiterInfo.delimiterIndex + delimiterInfo.delimiterLength;
            delimiterInfo= nextDelimiterInfo(text, start);
        }
        return count;
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineDelimiter(int)
     */
    public final String getLineDelimiter(int line)  {
        int lines= fLines.size();

        if (line < 0 || line > lines)
            throw new BadLocationException();

        if (lines is 0)
            return null;

        if (line is lines)
            return null;

        Line l= cast(Line) fLines.get(line);
        return l.delimiter;
    }

    /**
     * Returns the information about the first delimiter found in the given text starting at the
     * given offset.
     *
     * @param text the text to be searched
     * @param offset the offset in the given text
     * @return the information of the first found delimiter or <code>null</code>
     */
    protected abstract AbstractLineTracker_DelimiterInfo nextDelimiterInfo(String text, int offset);

    /**
     * Creates the line structure for the given text. Newly created lines are inserted into the line
     * structure starting at the given position. Returns the number of newly created lines.
     *
     * @param text the text for which to create a line structure
     * @param insertPosition the position at which the newly created lines are inserted into the
     *        tracker's line structure
     * @param offset the offset of all newly created lines
     * @return the number of newly created lines
     */
    private int createLines(String text, int insertPosition, int offset) {

        int count= 0;
        int start= 0;
        AbstractLineTracker_DelimiterInfo delimiterInfo= nextDelimiterInfo(text, 0);

        while (delimiterInfo !is null && delimiterInfo.delimiterIndex > -1) {

            int index= delimiterInfo.delimiterIndex + (delimiterInfo.delimiterLength - 1);

            if (insertPosition + count >= fLines.size())
                fLines.add(new Line(offset + start, offset + index, delimiterInfo.delimiter));
            else
                fLines.add(insertPosition + count, new Line(offset + start, offset + index, delimiterInfo.delimiter));

            ++count;
            start= index + 1;
            delimiterInfo= nextDelimiterInfo(text, start);
        }

        if (start < text.length()) {
            if (insertPosition + count < fLines.size()) {
                // there is a line below the current
                Line l= cast(Line) fLines.get(insertPosition + count);
                int delta= text.length() - start;
                l.offset-= delta;
                l.length+= delta;
            } else {
                fLines.add(new Line(offset + start, offset + text.length() - 1, null));
                ++count;
            }
        }

        return count;
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#replace(int, int, java.lang.String)
     */
    public final void replace(int position, int length, String text)  {
        throw new UnsupportedOperationException();
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#set(java.lang.String)
     */
    public final void set(String text) {
        fLines.clear();
        if (text !is null) {
            fTextLength= text.length();
            createLines(text, 0, 0);
        }
    }

    /**
     * Returns the internal data structure, a {@link List} of {@link Line}s. Used only by
     * {@link TreeLineTracker#TreeLineTracker(ListLineTracker)}.
     *
     * @return the internal list of lines.
     */
    final List getLines() {
        return fLines;
    }
}
