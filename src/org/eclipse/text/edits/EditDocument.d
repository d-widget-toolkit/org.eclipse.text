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
module org.eclipse.text.edits.EditDocument;
import org.eclipse.text.edits.MalformedTreeException;
import org.eclipse.text.edits.TextEditGroup;
import org.eclipse.text.edits.RangeMarker;
import org.eclipse.text.edits.TextEditCopier;
import org.eclipse.text.edits.UndoEdit;
import org.eclipse.text.edits.InsertEdit;
import org.eclipse.text.edits.MoveSourceEdit;
import org.eclipse.text.edits.MoveTargetEdit;
import org.eclipse.text.edits.CopyTargetEdit;
import org.eclipse.text.edits.TextEditProcessor;
import org.eclipse.text.edits.TextEditVisitor;
import org.eclipse.text.edits.TextEdit;
import org.eclipse.text.edits.TreeIterationInfo;
import org.eclipse.text.edits.TextEditMessages;
import org.eclipse.text.edits.CopySourceEdit;
import org.eclipse.text.edits.ReplaceEdit;
import org.eclipse.text.edits.MultiTextEdit;
import org.eclipse.text.edits.UndoCollector;
import org.eclipse.text.edits.ISourceModifier;
import org.eclipse.text.edits.CopyingRangeMarker;
import org.eclipse.text.edits.DeleteEdit;



import java.lang.all;
import java.util.Set;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.BadPositionCategoryException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IDocumentListener;
import org.eclipse.jface.text.IDocumentPartitioner;
import org.eclipse.jface.text.IDocumentPartitioningListener;
import org.eclipse.jface.text.IPositionUpdater;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITypedRegion;
import org.eclipse.jface.text.Position;

class EditDocument : IDocument {

    private StringBuffer fBuffer;

    public this(String content) {
        fBuffer= new StringBuffer(content);
    }

    public void addDocumentListener(IDocumentListener listener) {
        throw new UnsupportedOperationException();
    }

    public void addDocumentPartitioningListener(IDocumentPartitioningListener listener) {
        throw new UnsupportedOperationException();
    }

    public void addPosition(Position position)  {
        throw new UnsupportedOperationException();
    }

    public void addPosition(String category, Position position)  {
        throw new UnsupportedOperationException();
    }

    public void addPositionCategory(String category) {
        throw new UnsupportedOperationException();
    }

    public void addPositionUpdater(IPositionUpdater updater) {
        throw new UnsupportedOperationException();
    }

    public void addPrenotifiedDocumentListener(IDocumentListener documentAdapter) {
        throw new UnsupportedOperationException();
    }

    public int computeIndexInCategory(String category, int offset)  {
        throw new UnsupportedOperationException();
    }

    public int computeNumberOfLines(String text) {
        throw new UnsupportedOperationException();
    }

    public ITypedRegion[] computePartitioning(int offset, int length)  {
        throw new UnsupportedOperationException();
    }

    public bool containsPosition(String category, int offset, int length) {
        throw new UnsupportedOperationException();
    }

    public bool containsPositionCategory(String category) {
        throw new UnsupportedOperationException();
    }

    public String get() {
        return fBuffer.toString();
    }

    public String get(int offset, int length)  {
        return fBuffer.substring(offset, offset + length);
    }

    public char getChar(int offset)  {
        throw new UnsupportedOperationException();
    }

    public String getContentType(int offset)  {
        throw new UnsupportedOperationException();
    }

    public IDocumentPartitioner getDocumentPartitioner() {
        throw new UnsupportedOperationException();
    }

    public String[] getLegalContentTypes() {
        throw new UnsupportedOperationException();
    }

    public String[] getLegalLineDelimiters() {
        throw new UnsupportedOperationException();
    }

    public int getLength() {
        return fBuffer.length();
    }

    public String getLineDelimiter(int line)  {
        throw new UnsupportedOperationException();
    }

    public IRegion getLineInformation(int line)  {
        throw new UnsupportedOperationException();
    }

    public IRegion getLineInformationOfOffset(int offset)  {
        throw new UnsupportedOperationException();
    }

    public int getLineLength(int line)  {
        throw new UnsupportedOperationException();
    }

    public int getLineOffset(int line)  {
        throw new UnsupportedOperationException();
    }

    public int getLineOfOffset(int offset)  {
        throw new UnsupportedOperationException();
    }

    public int getNumberOfLines() {
        throw new UnsupportedOperationException();
    }

    public int getNumberOfLines(int offset, int length)  {
        throw new UnsupportedOperationException();
    }

    public ITypedRegion getPartition(int offset)  {
        throw new UnsupportedOperationException();
    }

    public String[] getPositionCategories() {
        throw new UnsupportedOperationException();
    }

    public Position[] getPositions(String category)  {
        throw new UnsupportedOperationException();
    }

    public IPositionUpdater[] getPositionUpdaters() {
        throw new UnsupportedOperationException();
    }

    public void insertPositionUpdater(IPositionUpdater updater, int index) {
        throw new UnsupportedOperationException();
    }

    public void removeDocumentListener(IDocumentListener listener) {
        throw new UnsupportedOperationException();
    }

    public void removeDocumentPartitioningListener(IDocumentPartitioningListener listener) {
        throw new UnsupportedOperationException();
    }

    public void removePosition(Position position) {
        throw new UnsupportedOperationException();
    }

    public void removePosition(String category, Position position)  {
        throw new UnsupportedOperationException();
    }

    public void removePositionCategory(String category)  {
        throw new UnsupportedOperationException();
    }

    public void removePositionUpdater(IPositionUpdater updater) {
        throw new UnsupportedOperationException();
    }

    public void removePrenotifiedDocumentListener(IDocumentListener documentAdapter) {
        throw new UnsupportedOperationException();
    }

    public void replace(int offset, int length, String text)  {
        fBuffer.replace(offset, offset + length, text);
    }

    public int search(int startOffset, String findString, bool forwardSearch, bool caseSensitive, bool wholeWord)  {
        throw new UnsupportedOperationException();
    }

    public void set(String text) {
        throw new UnsupportedOperationException();
    }

    public void setDocumentPartitioner(IDocumentPartitioner partitioner) {
        throw new UnsupportedOperationException();
    }
}
