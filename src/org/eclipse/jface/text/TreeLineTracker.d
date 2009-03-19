/*******************************************************************************
 * Copyright (c) 2005, 2006 IBM Corporation and others.
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
module org.eclipse.jface.text.TreeLineTracker;
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
import org.eclipse.jface.text.IDocumentInformationMapping;
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


import java.lang.all;
import java.util.ListIterator;
import java.util.Arrays;
import java.util.List;
import java.util.LinkedList;
import java.util.Set;

import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.text.AbstractLineTracker;

/**
 * Abstract implementation of <code>ILineTracker</code>. It lets the definition of line
 * delimiters to subclasses. Assuming that '\n' is the only line delimiter, this abstract
 * implementation defines the following line scheme:
 * <ul>
 * <li> "" -> [0,0]
 * <li> "a" -> [0,1]
 * <li> "\n" -> [0,1], [1,0]
 * <li> "a\n" -> [0,2], [2,0]
 * <li> "a\nb" -> [0,2], [2,1]
 * <li> "a\nbc\n" -> [0,2], [2,3], [5,0]
 * </ul>
 * <p>
 * This class must be subclassed.
 * </p>
 * <p>
 * <strong>Performance:</strong> The query operations perform in <i>O(log n)</i> where <var>n</var>
 * is the number of lines in the document. The modification operations roughly perform in <i>O(l *
 * log n)</i> where <var>n</var> is the number of lines in the document and <var>l</var> is the
 * sum of the number of removed, added or modified lines.
 * </p>
 *
 * @since 3.2
 */
abstract class TreeLineTracker : ILineTracker {
    /*
     * Differential Balanced Binary Tree
     *
     * Assumption: lines cannot overlap => there exists a total ordering of the lines by their offset,
     * which is the same as the ordering by line number
     *
     * Base idea: store lines in a binary search tree
     *   - the key is the line number / line offset
     *     -> lookup_line is O(log n)
     *     -> lookup_offset is O(log n)
     *   - a change in a line somewhere will change any succeeding line numbers / line offsets
     *     -> replace is O(n)
     *
     * Differential tree: instead of storing the key (line number, line offset) directly, every node
     * stores the difference between its key and its parent's key
     *   - the sort key is still the line number / line offset, but it remains "virtual"
     *   - inserting a node (a line) really increases the virtual key of all succeeding nodes (lines), but this
     *     fact will not be realized in the key information encoded in the nodes.
     *     -> any change only affects the nodes in the node's parent chain, although more bookkeeping
     *         has to be done when changing a node or balancing the tree
     *        -> replace is O(log n)
     *     -> line offsets and line numbers have to be computed when walking the tree from the root /
     *         from a node
     *        -> still O(log n)
     *
     * The balancing algorithm chosen does not depend on the differential tree property. An AVL tree
     * implementation has been chosen for simplicity.
     */

    /*
     * Turns assertions on/off. Don't make this a a debug option for performance reasons - this way
     * the compiler can optimize the asserts away.
     */
    private static const bool ASSERT= false;

    /**
     * The empty delimiter of the last line. The last line and only the last line must have this
     * zero-length delimiter.
     */
    private static const String NO_DELIM= ""; //$NON-NLS-1$

    /**
     * A node represents one line. Its character and line offsets are 0-based and relative to the
     * subtree covered by the node. All nodes under the left subtree represent lines before, all
     * nodes under the right subtree lines after the current node.
     */
    private static final class Node {
        this(int length, String delimiter) {
            this.length= length;
            this.delimiter= delimiter;
        }
        /**
         * The line index in this node's line tree, or equivalently, the number of lines in the left
         * subtree.
         */
        int line;
        /**
         * The line offset in this node's line tree, or equivalently, the number of characters in
         * the left subtree.
         */
        int offset;
        /** The number of characters in this line. */
        int length;
        /** The line delimiter of this line, needed to answer the delimiter query. */
        String delimiter;
        /** The parent node, <code>null</code> if this is the root node. */
        Node parent;
        /** The left subtree, possibly <code>null</code>. */
        Node left;
        /** The right subtree, possibly <code>null</code>. */
        Node right;
        /** The balance factor. */
        byte balance;

        /*
         * @see java.lang.Object#toString()
         */
        public final override String toString() {
            String bal;
            switch (balance) {
                case 0:
                    bal= "="; //$NON-NLS-1$
                    break;
                case 1:
                    bal= "+"; //$NON-NLS-1$
                    break;
                case 2:
                    bal= "++"; //$NON-NLS-1$
                    break;
                case -1:
                    bal= "-"; //$NON-NLS-1$
                    break;
                case -2:
                    bal= "--"; //$NON-NLS-1$
                    break;
                default:
                    bal= Byte.toString(balance);
            }
            return Format("[{}+{}+{}|{}|{}]", offset, pureLength(), delimiter.length, line, bal ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$ //$NON-NLS-4$ //$NON-NLS-5$ //$NON-NLS-6$
        }

        /**
         * Returns the pure (without the line delimiter) length of this line.
         *
         * @return the pure line length
         */
        int pureLength() {
            return length - delimiter.length;
        }
    }

    /**
     * The root node of the tree, never <code>null</code>.
     */
    private Node fRoot;

    /**
     * Creates a new line tracker.
     */
    protected this() {
        fRoot= new Node(0, NO_DELIM);
    }

    /**
     * Package visible constructor for creating a tree tracker from a list tracker.
     *
     * @param tracker
     */
    this(ListLineTracker tracker) {
        fRoot= new Node(0, NO_DELIM);
        final List lines= tracker.getLines();
        final int n= lines.size();
        if (n is 0)
            return;

        Line line= cast(Line) lines.get(0);
        String delim= line.delimiter;
        if (delim is null)
            delim= NO_DELIM;
        int length= line.length;
        fRoot= new Node(length, delim);
        Node node= fRoot;

        for (int i= 1; i < n; i++) {
            line= cast(Line) lines.get(i);
            delim= line.delimiter;
            if (delim is null)
                delim= NO_DELIM;
            length= line.length;
            node= insertAfter(node, length, delim);
        }

        if (node.delimiter !is NO_DELIM)
            insertAfter(node, 0, NO_DELIM);

        if (ASSERT) checkTree();
    }

    /**
     * Returns the node (line) including a certain offset. If the offset is between two
     * lines, the line starting at <code>offset</code> is returned.
     * <p>
     * This means that for offsets smaller than the length, the following holds:
     * </p>
     * <p>
     * <code>line.offset <= offset < line.offset + offset.length</code>.
     * </p>
     * <p>
     * If <code>offset</code> is the document length, then this is true:
     * </p>
     * <p>
     * <code>offset= line.offset + line.length</code>.
     * </p>
     *
     * @param offset a document offset
     * @return the line starting at or containing <code>offset</code>
     * @throws BadLocationException if the offset is invalid
     */
    private Node nodeByOffset(int offset)  {
        /*
         * Works for any binary search tree.
         */
        int remaining= offset;
        Node node= fRoot;
        int line= 0;

        while (true) {
            if (node is null)
                fail(offset);

            if (remaining < node.offset) {
                node= node.left;
            } else {
                remaining -= node.offset;
                line+= node.line;
                if (remaining < node.length
                        || remaining is node.length && node.right is null) { // last line
                    break;
                }
                remaining -= node.length;
                line ++;
                node= node.right;
            }
        }

        return node;
    }
    /**
     * Returns the line number for the given offset. If the offset is between two lines, the line
     * starting at <code>offset</code> is returned. The last line is returned if
     * <code>offset</code> is equal to the document length.
     *
     * @param offset a document offset
     * @return the line number starting at or containing <code>offset</code>
     * @throws BadLocationException if the offset is invalid
     */
    private int lineByOffset(int offset)  {
        /*
         * Works for any binary search tree.
         */
        int remaining= offset;
        Node node= fRoot;
        int line= 0;

        while (true) {
            if (node is null)
                fail(offset);

            if (remaining < node.offset) {
                node= node.left;
            } else {
                remaining -= node.offset;
                line+= node.line;
                if (remaining < node.length || remaining is node.length && node.right is null) // last line
                    return  line;

                remaining -= node.length;
                line ++;
                node= node.right;
            }
        }
    }

    /**
     * Returns the node (line) with the given line number. Note that the last line is always
     * incomplete, i.e. has the {@link #NO_DELIM} delimiter.
     *
     * @param line a line number
     * @return the line with the given line number
     * @throws BadLocationException if the line is invalid
     */
    private Node nodeByLine(int line)  {
        /*
         * Works for any binary search tree.
         */
        int remaining= line;
        int offset= 0;
        Node node= fRoot;

        while (true) {
            if (node is null)
                fail(line);

            if (remaining is node.line)
                break;
            if (remaining < node.line) {
                node= node.left;
            } else {
                remaining -= node.line + 1;
                offset += node.offset + node.length;
                node= node.right;
            }
        }

        return node;
    }

    /**
     * Returns the offset for the given line number. Note that the
     * last line is always incomplete, i.e. has the {@link #NO_DELIM} delimiter.
     *
     * @param line a line number
     * @return the line offset with the given line number
     * @throws BadLocationException if the line is invalid
     */
    private int offsetByLine(int line)  {
        /*
         * Works for any binary search tree.
         */
        int remaining= line;
        int offset= 0;
        Node node= fRoot;

        while (true) {
            if (node is null)
                fail(line);

            if (remaining is node.line)
                return offset + node.offset;

            if (remaining < node.line) {
                node= node.left;
            } else {
                remaining -= node.line + 1;
                offset += node.offset + node.length;
                node= node.right;
            }
        }
    }

    /**
     * Left rotation - the given node is rotated down, its right child is rotated up, taking the
     * previous structural position of <code>node</code>.
     *
     * @param node the node to rotate around
     */
    private void rotateLeft(Node node) {
        if (ASSERT) Assert.isNotNull(node);
        Node child= node.right;
        if (ASSERT) Assert.isNotNull(child);
        bool leftChild= node.parent is null || node is node.parent.left;

        // restructure
        setChild(node.parent, child, leftChild);

        setChild(node, child.left, false);
        setChild(child, node, true);

        // update relative info
        // child becomes the new parent, its line and offset counts increase as the former parent
        // moves under child's left subtree
        child.line += node.line + 1;
        child.offset += node.offset + node.length;
    }

    /**
     * Right rotation - the given node is rotated down, its left child is rotated up, taking the
     * previous structural position of <code>node</code>.
     *
     * @param node the node to rotate around
     */
    private void rotateRight(Node node) {
        if (ASSERT) Assert.isNotNull(node);
        Node child= node.left;
        if (ASSERT) Assert.isNotNull(child);
        bool leftChild= node.parent is null || node is node.parent.left;

        setChild(node.parent, child, leftChild);

        setChild(node, child.right, true);
        setChild(child, node, false);

        // update relative info
        // node loses its left subtree, except for what it keeps in its new subtree
        // this is exactly the amount in child
        node.line -= child.line + 1;
        node.offset -= child.offset + child.length;
    }

    /**
     * Helper method for moving a child, ensuring that parent pointers are set correctly.
     *
     * @param parent the new parent of <code>child</code>, <code>null</code> to replace the
     *        root node
     * @param child the new child of <code>parent</code>, may be <code>null</code>
     * @param isLeftChild <code>true</code> if <code>child</code> shall become
     *        <code>parent</code>'s left child, <code>false</code> if it shall become
     *        <code>parent</code>'s right child
     */
    private void setChild(Node parent, Node child, bool isLeftChild) {
        if (parent is null) {
            if (child is null)
                fRoot= new Node(0, NO_DELIM);
            else
                fRoot= child;
        } else {
            if (isLeftChild)
                parent.left= child;
            else
                parent.right= child;
        }
        if (child !is null)
            child.parent= parent;
    }

    /**
     * A left rotation around <code>parent</code>, whose structural position is replaced by
     * <code>node</code>.
     *
     * @param node the node moving up and left
     * @param parent the node moving left and down
     */
    private void singleLeftRotation(Node node, Node parent) {
        rotateLeft(parent);
        node.balance= 0;
        parent.balance= 0;
    }

    /**
     * A right rotation around <code>parent</code>, whose structural position is replaced by
     * <code>node</code>.
     *
     * @param node the node moving up and right
     * @param parent the node moving right and down
     */
    private void singleRightRotation(Node node, Node parent) {
        rotateRight(parent);
        node.balance= 0;
        parent.balance= 0;
    }

    /**
     * A double left rotation, first rotating right around <code>node</code>, then left around
     * <code>parent</code>.
     *
     * @param node the node that will be rotated right
     * @param parent the node moving left and down
     */
    private void rightLeftRotation(Node node, Node parent) {
        Node child= node.left;
        rotateRight(node);
        rotateLeft(parent);
        if (child.balance is 1) {
            node.balance= 0;
            parent.balance= -1;
            child.balance= 0;
        } else if (child.balance is 0) {
            node.balance= 0;
            parent.balance= 0;
        } else if (child.balance is -1) {
            node.balance= 1;
            parent.balance= 0;
            child.balance= 0;
        }
    }

    /**
     * A double right rotation, first rotating left around <code>node</code>, then right around
     * <code>parent</code>.
     *
     * @param node the node that will be rotated left
     * @param parent the node moving right and down
     */
    private void leftRightRotation(Node node, Node parent) {
        Node child= node.right;
        rotateLeft(node);
        rotateRight(parent);
        if (child.balance is -1) {
            node.balance= 0;
            parent.balance= 1;
            child.balance= 0;
        } else if (child.balance is 0) {
            node.balance= 0;
            parent.balance= 0;
        } else if (child.balance is 1) {
            node.balance= -1;
            parent.balance= 0;
            child.balance= 0;
        }
    }

    /**
     * Inserts a line with the given length and delimiter after <code>node</code>.
     *
     * @param node the predecessor of the inserted node
     * @param length the line length of the inserted node
     * @param delimiter the delimiter of the inserted node
     * @return the inserted node
     */
    private Node insertAfter(Node node, int length, String delimiter) {
        /*
         * An insertion really shifts the key of all succeeding nodes. Hence we insert the added node
         * between node and the successor of node. The added node becomes either the right child
         * of the predecessor node, or the left child of the successor node.
         */
        Node added= new Node(length, delimiter);

        if (node.right is null)
            setChild(node, added, false);
        else
            setChild(successorDown(node.right), added, true);

        // parent chain update
        updateParentChain(added, length, 1);
        updateParentBalanceAfterInsertion(added);

        return added;
    }

    /**
     * Updates the balance information in the parent chain of node until it reaches the root or
     * finds a node whose balance violates the AVL constraint, which is the re-balanced.
     *
     * @param node the child of the first node that needs balance updating
     */
    private void updateParentBalanceAfterInsertion(Node node) {
        Node parent= node.parent;
        while (parent !is null) {
            if (node is parent.left)
                parent.balance--;
            else
                parent.balance++;

            switch (parent.balance) {
                case 1:
                case -1:
                    node= parent;
                    parent= node.parent;
                    continue;
                case -2:
                    rebalanceAfterInsertionLeft(node);
                    break;
                case 2:
                    rebalanceAfterInsertionRight(node);
                    break;
                case 0:
                    break;
                default:
                    if (ASSERT)
                        Assert.isTrue(false);
            }
            return;
        }
    }

    /**
     * Re-balances a node whose parent has a double positive balance.
     *
     * @param node the node to re-balance
     */
    private void rebalanceAfterInsertionRight(Node node) {
        Node parent= node.parent;
        if (node.balance is 1) {
            singleLeftRotation(node, parent);
        } else if (node.balance is -1) {
            rightLeftRotation(node, parent);
        } else if (ASSERT) {
            Assert.isTrue(false);
        }
    }

    /**
     * Re-balances a node whose parent has a double negative balance.
     *
     * @param node the node to re-balance
     */
    private void rebalanceAfterInsertionLeft(Node node) {
        Node parent= node.parent;
        if (node.balance is -1) {
            singleRightRotation(node, parent);
        } else if (node.balance is 1) {
            leftRightRotation(node, parent);
        } else if (ASSERT) {
            Assert.isTrue(false);
        }
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#replace(int, int, java.lang.String)
     */
    public final void replace(int offset, int length, String text)  {
        if (ASSERT) checkTree();

        // Inlined nodeByOffset as we need both node and offset
        int remaining= offset;
        Node first= fRoot;
        int firstNodeOffset;

        while (true) {
            if (first is null)
                fail(offset);

            if (remaining < first.offset) {
                first= first.left;
            } else {
                remaining -= first.offset;
                if (remaining < first.length
                        || remaining is first.length && first.right is null) { // last line
                    firstNodeOffset= offset - remaining;
                    break;
                }
                remaining -= first.length;
                first= first.right;
            }
        }
        // Inline nodeByOffset end
        if (ASSERT) Assert.isTrue(first !is null);

        Node last;
        if (offset + length < firstNodeOffset + first.length)
            last= first;
        else
            last= nodeByOffset(offset + length);
        if (ASSERT) Assert.isTrue(last !is null);

        int firstLineDelta= firstNodeOffset + first.length - offset;
        if (first is last)
            replaceInternal(first, text, length, firstLineDelta);
        else
            replaceFromTo(first, last, text, length, firstLineDelta);

        if (ASSERT) checkTree();
    }

    /**
     * Replace happening inside a single line.
     *
     * @param node the affected node
     * @param text the added text
     * @param length the replace length, &lt; <code>firstLineDelta</code>
     * @param firstLineDelta the number of characters from the replacement offset to the end of
     *        <code>node</code> &gt; <code>length</code>
     */
    private void replaceInternal(Node node, String text, int length, int firstLineDelta) {
        // 1) modification on a single line

        AbstractLineTracker_DelimiterInfo info= text is null ? null : nextDelimiterInfo(text, 0);

        if (info is null || info.delimiter is null) {
            // a) trivial case: insert into a single node, no line mangling
            int added= text is null ? 0 : text.length;
            updateLength(node, added - length);
        } else {
            // b) more lines to add between two chunks of the first node
            // remember what we split off the first line
            int remainder= firstLineDelta - length;
            String remDelim= node.delimiter;

            // join the first line with the first added
            int consumed= info.delimiterIndex + info.delimiterLength;
            int delta= consumed - firstLineDelta;
            updateLength(node, delta);
            node.delimiter= info.delimiter;

            // Inline addlines start
            info= nextDelimiterInfo(text, consumed);
            while (info !is null) {
                int lineLen= info.delimiterIndex - consumed + info.delimiterLength;
                node= insertAfter(node, lineLen, info.delimiter);
                consumed += lineLen;
                info= nextDelimiterInfo(text, consumed);
            }
            // Inline addlines end

            // add remaining chunk merged with last (incomplete) additional line
            insertAfter(node, remainder + text.length - consumed, remDelim);
        }
    }

    /**
     * Replace spanning from one node to another.
     *
     * @param node the first affected node
     * @param last the last affected node
     * @param text the added text
     * @param length the replace length, &gt;= <code>firstLineDelta</code>
     * @param firstLineDelta the number of characters removed from the replacement offset to the end
     *        of <code>node</code>, &lt;= <code>length</code>
     */
    private void replaceFromTo(Node node, Node last, String text, int length, int firstLineDelta) {
        // 2) modification covers several lines

        // delete intermediate nodes
        // TODO could be further optimized: replace intermediate lines with intermediate added lines
        // to reduce re-balancing
        Node successor_= successor(node);
        while (successor_ !is last) {
            length -= successor_.length;
            Node toDelete= successor_;
            successor_= successor(successor_);
            updateLength(toDelete, -toDelete.length);
        }

        AbstractLineTracker_DelimiterInfo info= text is null ? null : nextDelimiterInfo(text, 0);

        if (info is null || info.delimiter is null) {
            int added= text is null ? 0 : text.length;

            // join the two lines if there are no lines added
            join(node, last, added - length);

        } else {

            // join the first line with the first added
            int consumed= info.delimiterIndex + info.delimiterLength;
            updateLength(node, consumed - firstLineDelta);
            node.delimiter= info.delimiter;
            length -= firstLineDelta;

            // Inline addLines start
            info= nextDelimiterInfo(text, consumed);
            while (info !is null) {
                int lineLen= info.delimiterIndex - consumed + info.delimiterLength;
                node= insertAfter(node, lineLen, info.delimiter);
                consumed += lineLen;
                info= nextDelimiterInfo(text, consumed);
            }
            // Inline addLines end

            updateLength(last, text.length - consumed - length);
        }
    }

    /**
     * Joins two consecutive node lines, additionally adjusting the resulting length of the combined
     * line by <code>delta</code>. The first node gets deleted.
     *
     * @param one the first node to join
     * @param two the second node to join
     * @param delta the delta to apply to the remaining single node
     */
    private void join(Node one, Node two, int delta) {
        int oneLength= one.length;
        updateLength(one, -oneLength);
        updateLength(two, oneLength + delta);
    }

    /**
     * Adjusts the length of a node by <code>delta</code>, also adjusting the parent chain of
     * <code>node</code>. If the node's length becomes zero and is not the last (incomplete)
     * node, it is deleted after the update.
     *
     * @param node the node to adjust
     * @param delta the character delta to add to the node's length
     */
    private void updateLength(Node node, int delta) {
        if (ASSERT) Assert.isTrue(node.length  + delta >= 0);

        // update the node itself
        node.length += delta;

        // check deletion
        int lineDelta;
        bool delete__= node.length is 0 && node.delimiter !is NO_DELIM;
        if (delete__)
            lineDelta= -1;
        else
            lineDelta= 0;

        // update parent chain
        if (delta !is 0 || lineDelta !is 0)
            updateParentChain(node, delta, lineDelta);

        if (delete__)
            delete_(node);
    }

    /**
     * Updates the differential indices following the parent chain. All nodes from
     * <code>from.parent</code> to the root are updated.
     *
     * @param node the child of the first node to update
     * @param deltaLength the character delta
     * @param deltaLines the line delta
     */
    private void updateParentChain(Node node, int deltaLength, int deltaLines) {
        updateParentChain(node, null, deltaLength, deltaLines);
    }

    /**
     * Updates the differential indices following the parent chain. All nodes from
     * <code>from.parent</code> to <code>to</code> (exclusive) are updated.
     *
     * @param from the child of the first node to update
     * @param to the first node not to update
     * @param deltaLength the character delta
     * @param deltaLines the line delta
     */
    private void updateParentChain(Node from, Node to, int deltaLength, int deltaLines) {
        Node parent= from.parent;
        while (parent !is to) {
            // only update node if update comes from left subtree
            if (from is parent.left) {
                parent.offset += deltaLength;
                parent.line += deltaLines;
            }
            from= parent;
            parent= from.parent;
        }
    }

    /**
     * Deletes a node from the tree, re-balancing it if necessary. The differential indices in the
     * node's parent chain have to be updated in advance to calling this method. Generally, don't
     * call <code>delete</code> directly, but call
     * {@link #updateLength(Node, int) update_length(node, -node.length)} to properly remove a
     * node.
     *
     * @param node the node to delete.
     */
    private void delete_(Node node) {
        if (ASSERT) Assert.isTrue(node !is null);
        if (ASSERT) Assert.isTrue(node.length is 0);

        Node parent= node.parent;
        Node toUpdate; // the parent of the node that lost a child
        bool lostLeftChild;
        bool isLeftChild= parent is null || node is parent.left;

        if (node.left is null || node.right is null) {
            // 1) node has one child at max - replace parent's pointer with the only child
            // also handles the trivial case of no children
            Node replacement= node.left is null ? node.right : node.left;
            setChild(parent, replacement, isLeftChild);
            toUpdate= parent;
            lostLeftChild= isLeftChild;
            // no updates to do - subtrees stay as they are
        } else if (node.right.left is null) {
            // 2a) node's right child has no left child - replace node with right child, giving node's
            // left subtree to the right child
            Node replacement= node.right;
            setChild(parent, replacement, isLeftChild);
            setChild(replacement, node.left, true);
            replacement.line= node.line;
            replacement.offset= node.offset;
            replacement.balance= node.balance;
            toUpdate= replacement;
            lostLeftChild= false;
//      } else if (node.left.right is null) {
//          // 2b) symmetric case
//          Node replacement= node.left;
//          set_child(parent, replacement, isLeftChild);
//          set_child(replacement, node.right, false);
//          replacement.balance= node.balance;
//          toUpdate= replacement;
//          lostLeftChild= true;
        } else {
            // 3) hard case - replace node with its successor
            Node successor_= successor(node);

            // successor exists (otherwise node would not have right child, case 1)
            if (ASSERT) Assert.isNotNull(successor_);
            // successor has no left child (a left child would be the real successor of node)
            if (ASSERT) Assert.isTrue(successor_.left is null);
            if (ASSERT) Assert.isTrue(successor_.line is 0);
            // successor is the left child of its parent (otherwise parent would be smaller and
            // hence the real successor)
            if (ASSERT) Assert.isTrue(successor_ is successor_.parent.left);
            // successor is not a child of node (would have been covered by 2a)
            if (ASSERT) Assert.isTrue(successor_.parent !is node);

            toUpdate= successor_.parent;
            lostLeftChild= true;

            // update relative indices
            updateParentChain(successor_, node, -successor_.length, -1);

            // delete successor from its current place - like 1)
            setChild(toUpdate, successor_.right, true);

            // move node's subtrees to its successor
            setChild(successor_, node.right, false);
            setChild(successor_, node.left, true);

            // replace node by successor in its parent
            setChild(parent, successor_, isLeftChild);

            // update the successor
            successor_.line= node.line;
            successor_.offset= node.offset;
            successor_.balance= node.balance;
        }

        updateParentBalanceAfterDeletion(toUpdate, lostLeftChild);
    }

    /**
     * Updates the balance information in the parent chain of node.
     *
     * @param node the first node that needs balance updating
     * @param wasLeftChild <code>true</code> if the deletion happened on <code>node</code>'s
     *        left subtree, <code>false</code> if it occurred on <code>node</code>'s right
     *        subtree
     */
    private void updateParentBalanceAfterDeletion(Node node, bool wasLeftChild) {
        while (node !is null) {
            if (wasLeftChild)
                node.balance++;
            else
                node.balance--;

            Node parent= node.parent;
            if (parent !is null)
                wasLeftChild= node is parent.left;

            switch (node.balance) {
                case 1:
                case -1:
                    return; // done, no tree change
                case -2:
                    if (rebalanceAfterDeletionRight(node.left))
                        return;
                    break; // propagate up
                case 2:
                    if (rebalanceAfterDeletionLeft(node.right))
                        return;
                    break; // propagate up
                case 0:
                    break; // propagate up
                default:
                    if (ASSERT)
                        Assert.isTrue(false);
            }

            node= parent;
        }
    }

    /**
     * Re-balances a node whose parent has a double positive balance.
     *
     * @param node the node to re-balance
     * @return <code>true</code> if the re-balancement leaves the height at
     *         <code>node.parent</code> constant, <code>false</code> if the height changed
     */
    private bool rebalanceAfterDeletionLeft(Node node) {
        Node parent= node.parent;
        if (node.balance is 1) {
            singleLeftRotation(node, parent);
            return false;
        } else if (node.balance is -1) {
            rightLeftRotation(node, parent);
            return false;
        } else if (node.balance is 0) {
            rotateLeft(parent);
            node.balance= -1;
            parent.balance= 1;
            return true;
        } else {
            if (ASSERT) Assert.isTrue(false);
            return true;
        }
    }

    /**
     * Re-balances a node whose parent has a double negative balance.
     *
     * @param node the node to re-balance
     * @return <code>true</code> if the re-balancement leaves the height at
     *         <code>node.parent</code> constant, <code>false</code> if the height changed
     */
    private bool rebalanceAfterDeletionRight(Node node) {
        Node parent= node.parent;
        if (node.balance is -1) {
            singleRightRotation(node, parent);
            return false;
        } else if (node.balance is 1) {
            leftRightRotation(node, parent);
            return false;
        } else if (node.balance is 0) {
            rotateRight(parent);
            node.balance= 1;
            parent.balance= -1;
            return true;
        } else {
            if (ASSERT) Assert.isTrue(false);
            return true;
        }
    }

    /**
     * Returns the successor of a node, <code>null</code> if node is the last node.
     *
     * @param node a node
     * @return the successor of <code>node</code>, <code>null</code> if there is none
     */
    private Node successor(Node node) {
        if (node.right !is null)
            return successorDown(node.right);

        return successorUp(node);
    }

    /**
     * Searches the successor of <code>node</code> in its parent chain.
     *
     * @param node a node
     * @return the first node in <code>node</code>'s parent chain that is reached from its left
     *         subtree, <code>null</code> if there is none
     */
    private Node successorUp(Node node) {
        Node child= node;
        Node parent= child.parent;
        while (parent !is null) {
            if (child is parent.left)
                return parent;
            child= parent;
            parent= child.parent;
        }
        if (ASSERT) Assert.isTrue(node.delimiter is NO_DELIM);
        return null;
    }

    /**
     * Searches the left-most node in a given subtree.
     *
     * @param node a node
     * @return the left-most node in the given subtree
     */
    private Node successorDown(Node node) {
        Node child= node.left;
        while (child !is null) {
            node= child;
            child= node.left;
        }
        return node;
    }

    /* miscellaneous */

    /**
     * Throws an exception.
     *
     * @param offset the illegal character or line offset that caused the exception
     * @throws BadLocationException always
     */
    private void fail(int offset)  {
        throw new BadLocationException();
    }

    /**
     * Returns the information about the first delimiter found in the given
     * text starting at the given offset.
     *
     * @param text the text to be searched
     * @param offset the offset in the given text
     * @return the information of the first found delimiter or <code>null</code>
     */
    protected abstract AbstractLineTracker_DelimiterInfo nextDelimiterInfo(String text, int offset);

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineDelimiter(int)
     */
    public final String getLineDelimiter(int line)  {
        Node node= nodeByLine(line);
        return node.delimiter is NO_DELIM ? null : node.delimiter;
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
     * @see org.eclipse.jface.text.ILineTracker#getNumberOfLines()
     */
    public final int getNumberOfLines() {
        // TODO track separately?
        Node node= fRoot;
        int lines= 0;
        while (node !is null) {
            lines += node.line + 1;
            node= node.right;
        }
        return lines;
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getNumberOfLines(int, int)
     */
    public final int getNumberOfLines(int offset, int length)  {
        if (length is 0)
            return 1;

        int startLine= lineByOffset(offset);
        int endLine= lineByOffset(offset + length);

        return endLine - startLine + 1;
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineOffset(int)
     */
    public final int getLineOffset(int line)  {
        return offsetByLine(line);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineLength(int)
     */
    public final int getLineLength(int line)  {
        Node node= nodeByLine(line);
        return node.length;
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineNumberOfOffset(int)
     */
    public final int getLineNumberOfOffset(int offset)  {
        return lineByOffset(offset);
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineInformationOfOffset(int)
     */
    public final IRegion getLineInformationOfOffset(int offset)  {
        // Inline nodeByOffset start as we need both node and offset
        int remaining= offset;
        Node node= fRoot;
        int lineOffset;

        while (true) {
            if (node is null)
                fail(offset);

            if (remaining < node.offset) {
                node= node.left;
            } else {
                remaining -= node.offset;
                if (remaining < node.length
                        || remaining is node.length && node.right is null) { // last line
                    lineOffset= offset - remaining;
                    break;
                }
                remaining -= node.length;
                node= node.right;
            }
        }
        // Inline nodeByOffset end
        return new Region(lineOffset, node.pureLength());
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLineInformation(int)
     */
    public final IRegion getLineInformation(int line)  {
        try {
            // Inline nodeByLine start
            int remaining= line;
            int offset= 0;
            Node node= fRoot;

            while (true) {
                if (node is null)
                    fail(line);

                if (remaining is node.line) {
                    offset += node.offset;
                    break;
                }
                if (remaining < node.line) {
                    node= node.left;
                } else {
                    remaining -= node.line + 1;
                    offset += node.offset + node.length;
                    node= node.right;
                }
            }
            // Inline nodeByLine end
            return new Region(offset, node.pureLength());
        } catch (BadLocationException x) {
            /*
             * FIXME: this really strange behavior is mandated by the previous line tracker
             * implementation and included here for compatibility. See
             * LineTrackerTest3#testFunnyLastLineCompatibility().
             */
            if (line > 0 && line is getNumberOfLines()) {
                line= line - 1;
                // Inline nodeByLine start
                int remaining= line;
                int offset= 0;
                Node node= fRoot;

                while (true) {
                    if (node is null)
                        fail(line);

                    if (remaining is node.line) {
                        offset+= node.offset;
                        break;
                    }
                    if (remaining < node.line) {
                        node= node.left;
                    } else {
                        remaining -= node.line + 1;
                        offset += node.offset + node.length;
                        node= node.right;
                    }
                }
                Node last= node;
                // Inline nodeByLine end
                if (last.length > 0)
                    return new Region(offset + last.length, 0);
            }
            throw x;
        }
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#set(java.lang.String)
     */
    public final void set(String text) {
        fRoot= new Node(0, NO_DELIM);
        try {
            replace(0, 0, text);
        } catch (BadLocationException x) {
            throw new InternalError(__FILE__,__LINE__);
        }
    }

    /*
     * @see java.lang.Object#toString()
     */
    public override String toString() {
        int depth= computeDepth(fRoot);
        int WIDTH= 30;
        int leaves= cast(int) Math.pow( cast(real)2, cast(uint) depth - 1);
        int width= WIDTH * leaves;
        String empty= "."; //$NON-NLS-1$

        List roots= new LinkedList();
        roots.add(fRoot);
        StringBuffer buf= new StringBuffer((width + 1) * depth);
        int nodes= 1;
        int indents= leaves;
        char[] space= new char[leaves * WIDTH / 2];
        Arrays.fill(space, ' ');
        for(int d= 0; d < depth; d++) {
            // compute indent
            indents /= 2;
            int spaces= Math.max(0, indents * WIDTH - WIDTH / 2);
            // print nodes
            for (ListIterator it= roots.listIterator(); it.hasNext();) {
                // pad before
                buf.append(space[ 0 .. spaces]);

                Node node= cast(Node) it.next();
                String box;
                // replace the node with its children
                if (node is null) {
                    it.add(cast(Object)null);
                    box= empty;
                } else {
                    it.set(node.left);
                    it.add(node.right);
                    box= node.toString();
                }

                // draw the node, pad to WIDTH
                int pad_left= (WIDTH - box.length() + 1) / 2;
                int pad_right= WIDTH - box.length() - pad_left;
                buf.append(space[ 0 .. pad_left]);
                buf.append(box);
                buf.append(space[ 0 .. pad_right]);

                // pad after
                buf.append(space[ 0 .. spaces]);
            }

            buf.append('\n');
            nodes *= 2;
        }

        return buf.toString();
    }

    /**
     * Recursively computes the depth of the tree. Only used by {@link #toString()}.
     *
     * @param root the subtree to compute the depth of, may be <code>null</code>
     * @return the depth of the given tree, 0 if it is <code>null</code>
     */
    private byte computeDepth(Node root) {
        if (root is null)
            return 0;

        return cast(byte) (Math.max(computeDepth(root.left), computeDepth(root.right)) + 1);
    }

    /**
     * Debug-only method that checks the tree structure and the differential offsets.
     */
    private void checkTree() {
        checkTreeStructure(fRoot);

        try {
            checkTreeOffsets(nodeByOffset(0), [0, 0], null);
        } catch (BadLocationException x) {
            throw new InternalError(__FILE__,__LINE__);
        }
    }

    /**
     * Debug-only method that validates the tree structure below <code>node</code>. I.e. it
     * checks whether all parent/child pointers are consistent and whether the AVL balance
     * information is correct.
     *
     * @param node the node to validate
     * @return the depth of the tree under <code>node</code>
     */
    private byte checkTreeStructure(Node node) {
        if (node is null)
            return 0;

        byte leftDepth= checkTreeStructure(node.left);
        byte rightDepth= checkTreeStructure(node.right);
        Assert.isTrue(node.balance is rightDepth - leftDepth);
        Assert.isTrue(node.left is null || node.left.parent is node);
        Assert.isTrue(node.right is null || node.right.parent is node);

        return cast(byte) (Math.max(rightDepth, leftDepth) + 1);
    }

    /**
     * Debug-only method that checks the differential offsets of the tree, starting at
     * <code>node</code> and continuing until <code>last</code>.
     *
     * @param node the first <code>Node</code> to check, may be <code>null</code>
     * @param offLen an array of length 2, with <code>offLen[0]</code> the expected offset of
     *        <code>node</code> and <code>offLen[1]</code> the expected line of
     *        <code>node</code>
     * @param last the last <code>Node</code> to check, may be <code>null</code>
     * @return an <code>int[]</code> of length 2, with the first element being the character
     *         length of <code>node</code>'s subtree, and the second element the number of lines
     *         in <code>node</code>'s subtree
     */
    private int[] checkTreeOffsets(Node node, int[] offLen, Node last) {
        if (node is last)
            return offLen;

        Assert.isTrue(node.offset is offLen[0]);
        Assert.isTrue(node.line is offLen[1]);

        if (node.right !is null) {
            int[] result= checkTreeOffsets(successorDown(node.right), new int[2], node);
            offLen[0] += result[0];
            offLen[1] += result[1];
        }

        offLen[0] += node.length;
        offLen[1]++;
        return checkTreeOffsets(node.parent, offLen, last);
    }
}
