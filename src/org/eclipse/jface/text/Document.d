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
module org.eclipse.jface.text.Document;
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
 * Default document implementation. Uses a {@link org.eclipse.jface.text.GapTextStore} wrapped
 * inside a {@link org.eclipse.jface.text.CopyOnWriteTextStore} as text store.
 * <p>
 * The used line tracker considers the following strings as line delimiters: "\n", "\r", "\r\n".
 * </p>
 * <p>
 * The document is ready to use. It has a default position category for which a default position
 * updater is installed.
 * </p>
 * <p>
 * <strong>Performance:</strong> The implementation should perform reasonably well for typical
 * source code documents. It is not designed for very large documents of a size of several
 * megabytes. Space-saving implementations are initially used for both the text store and the line
 * tracker; the first modification after a {@link #set(String) set} incurs the cost to transform the
 * document structures to efficiently handle updates.
 * </p>
 * <p>
 * See {@link GapTextStore} and <code>TreeLineTracker</code> for algorithmic behavior of the used
 * document structures.
 * </p>
 *
 * @see org.eclipse.jface.text.GapTextStore
 * @see org.eclipse.jface.text.CopyOnWriteTextStore
 */
public class Document : AbstractDocument {
    /**
     * Creates a new empty document.
     */
    public this() {
        super();
        setTextStore(new CopyOnWriteTextStore(new GapTextStore()));
        setLineTracker(new DefaultLineTracker());
        completeInitialization();
    }

    /**
     * Creates a new document with the given initial content.
     *
     * @param initialContent the document's initial content
     */
    public this(String initialContent) {
        super();
        setTextStore(new CopyOnWriteTextStore(new GapTextStore()));
        setLineTracker(new DefaultLineTracker());
        getStore().set(initialContent);
        getTracker().set(initialContent);
        completeInitialization();
    }

    /*
     * @see org.eclipse.jface.text.IRepairableDocumentExtension#isLineInformationRepairNeeded(int, int, java.lang.String)
     * @since 3.4
     */
    public bool isLineInformationRepairNeeded(int offset, int length, String text)  {
        if ((0 > offset) || (0 > length) || (offset + length > getLength()))
            throw new BadLocationException();

        return isLineInformationRepairNeeded(text) || isLineInformationRepairNeeded(get(offset, length));
    }

    /**
     * Checks whether the line information needs to be repaired.
     *
     * @param text the text to check
     * @return <code>true</code> if the line information must be repaired
     * @since 3.4
     */
    private bool isLineInformationRepairNeeded(String text) {
        if (text is null)
            return false;

        int length= text.length();
        if (length is 0)
            return false;

        int rIndex= text.indexOf('\r');
        int nIndex= text.indexOf('\n');
        if (rIndex is -1 && nIndex is -1)
            return false;

        if (rIndex > 0 && rIndex < length-1 && nIndex > 1 && rIndex < length-2)
            return false;

        String defaultLD= null;
        try {
            defaultLD= getLineDelimiter(0);
        } catch (BadLocationException x) {
            return true;
        }

        if (defaultLD is null)
            return false;

        defaultLD= getDefaultLineDelimiter();

        if (defaultLD.length is 1) {
            if (rIndex !is -1 && !"\r".equals(defaultLD)) //$NON-NLS-1$
                return true;
            if (nIndex !is -1 && !"\n".equals(defaultLD)) //$NON-NLS-1$
                return true;
        } else if (defaultLD.length is 2)
            return rIndex is -1 || nIndex - rIndex !is 1;

        return false;
    }

}
