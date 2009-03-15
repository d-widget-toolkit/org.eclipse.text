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
module org.eclipse.jface.text.DefaultLineTracker;
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
 * Standard implementation of {@link org.eclipse.jface.text.ILineTracker}.
 * <p>
 * The line tracker considers the three common line delimiters which are '\n',
 * '\r', '\r\n'.
 * <p>
 * This class is not intended to be subclassed.
 * </p>
 * @noextend This class is not intended to be subclassed by clients.
 */
public class DefaultLineTracker : AbstractLineTracker {

    /** The predefined delimiters of this tracker */
    public const static String[] DELIMITERS= [ "\r", "\n", "\r\n" ]; //$NON-NLS-3$ //$NON-NLS-1$ //$NON-NLS-2$
    /** A predefined delimiter information which is always reused as return value */
    private AbstractLineTracker_DelimiterInfo fDelimiterInfo;


    /**
     * Creates a standard line tracker.
     */
    public this() {
        fDelimiterInfo= new AbstractLineTracker_DelimiterInfo();
    }

    /*
     * @see org.eclipse.jface.text.ILineTracker#getLegalLineDelimiters()
     */
    public String[] getLegalLineDelimiters() {
        return TextUtilities.copy(DELIMITERS);
    }

    /*
     * @see org.eclipse.jface.text.AbstractLineTracker#nextDelimiterInfo(java.lang.String, int)
     */
    protected AbstractLineTracker_DelimiterInfo nextDelimiterInfo(String text, int offset) {

        char ch;
        int length= text.length();
        for (int i= offset; i < length; i++) {

            ch= text.charAt(i);
            if (ch is '\r') {

                if (i + 1 < length) {
                    if (text.charAt(i + 1) is '\n') {
                        fDelimiterInfo.delimiter= DELIMITERS[2];
                        fDelimiterInfo.delimiterIndex= i;
                        fDelimiterInfo.delimiterLength= 2;
                        return fDelimiterInfo;
                    }
                }

                fDelimiterInfo.delimiter= DELIMITERS[0];
                fDelimiterInfo.delimiterIndex= i;
                fDelimiterInfo.delimiterLength= 1;
                return fDelimiterInfo;

            } else if (ch is '\n') {

                fDelimiterInfo.delimiter= DELIMITERS[1];
                fDelimiterInfo.delimiterIndex= i;
                fDelimiterInfo.delimiterLength= 1;
                return fDelimiterInfo;
            }
        }

        return null;
    }
}
