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
module org.eclipse.text.edits.TextEditGroup;
import org.eclipse.text.edits.MalformedTreeException;
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
import org.eclipse.text.edits.EditDocument;
import org.eclipse.text.edits.UndoCollector;
import org.eclipse.text.edits.ISourceModifier;
import org.eclipse.text.edits.CopyingRangeMarker;
import org.eclipse.text.edits.DeleteEdit;



import java.lang.all;
import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;




import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.text.IRegion;


/**
 * A text edit group combines a list of {@link TextEdit}s
 * and a name into a single object. The name must be a human
 * readable string use to present the text edit group in the
 * user interface.
 * <p>
 * Clients may extend this class to add extra information to
 * a text edit group.
 * </p>
 *
 * @since 3.0
 */
public class TextEditGroup {

    private String fDescription;
    private List fEdits;

    /**
     * Creates a new text edit group with the given name.
     *
     * @param name the name of the text edit group. Must be
     *  a human readable string
     */
    public this(String name) {
//         super();
        Assert.isNotNull(name);
        fDescription= name;
        fEdits= new ArrayList(3);
    }

    /**
     * Creates a new text edit group with a name and a single
     * {@link TextEdit}.
     *
     * @param name the name of the text edit group. Must be
     *  a human readable string
     * @param edit the edit to manage
     */
    public this(String name, TextEdit edit) {
        Assert.isNotNull(name);
        Assert.isNotNull(edit);
        fDescription= name;
        fEdits= new ArrayList(1);
        fEdits.add(edit);
    }

    /**
     * Creates a new text edit group with the given name and
     * array of edits.
     *
     * @param name the name of the text edit group. Must be
     *  a human readable string
     * @param edits the array of edits
     */
    public this(String name, TextEdit[] edits) {
//         super();
        Assert.isNotNull(name);
        Assert.isTrue(edits !is null);
        fDescription= name;
        fEdits= new ArrayList(Arrays.asList(edits));
    }

    /**
     * Returns the edit group's name.
     *
     * @return the edit group's name
     */
    public String getName() {
        return fDescription;
    }

    /**
     * Adds the given {@link TextEdit} to this group.
     *
     * @param edit the edit to add
     */
    public void addTextEdit(TextEdit edit) {
        fEdits.add(edit);
    }

    /**
     * Removes the given {@link TextEdit} from this group.
     *
     * @param edit the edit to remove
     * @return <code>true</code> if this group contained the specified edit.
     * @since 3.3
     */
    public bool removeTextEdit(TextEdit edit) {
      return fEdits.remove(edit);
    }

    /**
     * Removes all text edits from this group.
     *
     * @since 3.3
     */
    public void clearTextEdits() {
      fEdits.clear();
    }



    /**
     * Returns <code>true</code> if the list of managed
     * {@link TextEdit}s is empty; otherwise <code>false
     * </code> is returned.
     *
     * @return whether the list of managed text edits is
     *  empty or not
     */
    public bool isEmpty() {
        return fEdits.isEmpty();
    }

    /**
     * Returns an array of {@link TextEdit}s containing
     * the edits managed by this group.
     *
     * @return the managed text edits
     */
    public TextEdit[] getTextEdits() {
        return arraycast!(TextEdit)( fEdits.toArray());
    }

    /**
     * Returns the text region covered by the edits managed via this
     * edit group. If the group doesn't manage any edits <code>null
     * </code> is returned.
     *
     * @return the text region covered by this edit group or <code>
     *  null</code> if no edits are managed
     */
    public IRegion getRegion() {
        int size= fEdits.size();
        if (size is 0) {
            return null;
        } else if (size is 1) {
            return (cast(TextEdit)fEdits.get(0)).getRegion();
        } else {
            return TextEdit.getCoverage(arraycast!(TextEdit)(fEdits.toArray()));
        }
    }
}
