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
module org.eclipse.jface.text.Assert;
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


/**
 * <code>Assert</code> is useful for for embedding runtime sanity checks
 * in code. The static predicate methods all test a condition and throw some
 * type of unchecked exception if the condition does not hold.
 * <p>
 * Assertion failure exceptions, like most runtime exceptions, are
 * thrown when something is misbehaving. Assertion failures are invariably
 * unspecified behavior; consequently, clients should never rely on
 * these being thrown (or not thrown). <b>If you find yourself in the
 * position where you need to catch an assertion failure, you have most
 * certainly written your program incorrectly.</b>
 * </p>
 * <p>
 * Note that an <code>assert</code> statement is slated to be added to the
 * Java language in JDK 1.4, rending this class obsolete.
 * </p>
 *
 * @deprecated As of 3.3, replaced by {@link org.eclipse.core.runtime.Assert}
 * @noinstantiate This class is not intended to be instantiated by clients.
 */
public final class Assert {

        /**
         * <code>AssertionFailedException</code> is a runtime exception thrown
         * by some of the methods in <code>Assert</code>.
         * <p>
         * This class is not declared public to prevent some misuses; programs that catch
         * or otherwise depend on assertion failures are susceptible to unexpected
         * breakage when assertions in the code are added or removed.
         * </p>
         * <p>
         * This class is not intended to be serialized.
         * </p>
         */
        private static class AssertionFailedException : RuntimeException {

            /**
             * Serial version UID for this class.
             * <p>
             * Note: This class is not intended to be serialized.
             * </p>
             * @since 3.1
             */
            private static const long serialVersionUID= 3689918374733886002L;

            /**
             * Constructs a new exception.
             */
            public this() {
            }

            /**
             * Constructs a new exception with the given message.
             *
             * @param detail the detailed message
             */
            public this(String detail) {
                super(detail);
            }
        }

    /* This class is not intended to be instantiated. */
    private this() {
    }

    /**
     * Asserts that an argument is legal. If the given bool is
     * not <code>true</code>, an <code>IllegalArgumentException</code>
     * is thrown.
     *
     * @param expression the outcome of the check
     * @return <code>true</code> if the check passes (does not return
     *    if the check fails)
     * @exception IllegalArgumentException if the legality test failed
     */
    public static bool isLegal(bool expression) {
        // succeed as quickly as possible
        if (expression) {
            return true;
        }
        return isLegal(expression, "");//$NON-NLS-1$
    }

    /**
     * Asserts that an argument is legal. If the given bool is
     * not <code>true</code>, an <code>IllegalArgumentException</code>
     * is thrown.
     * The given message is included in that exception, to aid debugging.
     *
     * @param expression the outcome of the check
     * @param message the message to include in the exception
     * @return <code>true</code> if the check passes (does not return
     *    if the check fails)
     * @exception IllegalArgumentException if the legality test failed
     */
    public static bool isLegal(bool expression, String message) {
        if (!expression)
            throw new IllegalArgumentException("assertion failed; " ~ message); //$NON-NLS-1$
        return expression;
    }

    /**
     * Asserts that the given object is not <code>null</code>. If this
     * is not the case, some kind of unchecked exception is thrown.
     * <p>
     * As a general rule, parameters passed to API methods must not be
     * <code>null</code> unless <b>explicitly</b> allowed in the method's
     * specification. Similarly, results returned from API methods are never
     * <code>null</code> unless <b>explicitly</b> allowed in the method's
     * specification. Implementations are encouraged to make regular use of
     * <code>Assert.isNotNull</code> to ensure that <code>null</code>
     * parameters are detected as early as possible.
     * </p>
     *
     * @param object the value to test
     * @exception RuntimeException an unspecified unchecked exception if the object
     *   is <code>null</code>
     */
    public static void isNotNull(Object object) {
        // succeed as quickly as possible
        if (object !is null) {
            return;
        }
        isNotNull(object, "");//$NON-NLS-1$
    }

    /**
     * Asserts that the given object is not <code>null</code>. If this
     * is not the case, some kind of unchecked exception is thrown.
     * The given message is included in that exception, to aid debugging.
     * <p>
     * As a general rule, parameters passed to API methods must not be
     * <code>null</code> unless <b>explicitly</b> allowed in the method's
     * specification. Similarly, results returned from API methods are never
     * <code>null</code> unless <b>explicitly</b> allowed in the method's
     * specification. Implementations are encouraged to make regular use of
     * <code>Assert.isNotNull</code> to ensure that <code>null</code>
     * parameters are detected as early as possible.
     * </p>
     *
     * @param object the value to test
     * @param message the message to include in the exception
     * @exception RuntimeException an unspecified unchecked exception if the object
     *   is <code>null</code>
     */
    public static void isNotNull(Object object, String message) {
        if (object is null)
            throw new AssertionFailedException("null argument;" ~ message);//$NON-NLS-1$
    }

    /**
     * Asserts that the given bool is <code>true</code>. If this
     * is not the case, some kind of unchecked exception is thrown.
     *
     * @param expression the outcome of the check
     * @return <code>true</code> if the check passes (does not return
     *    if the check fails)
     */
    public static bool isTrue(bool expression) {
        // succeed as quickly as possible
        if (expression) {
            return true;
        }
        return isTrue(expression, "");//$NON-NLS-1$
    }

    /**
     * Asserts that the given bool is <code>true</code>. If this
     * is not the case, some kind of unchecked exception is thrown.
     * The given message is included in that exception, to aid debugging.
     *
     * @param expression the outcome of the check
     * @param message the message to include in the exception
     * @return <code>true</code> if the check passes (does not return
     *    if the check fails)
     */
    public static bool isTrue(bool expression, String message) {
        if (!expression)
            throw new AssertionFailedException("Assertion failed: "~message);//$NON-NLS-1$
        return expression;
    }
}
