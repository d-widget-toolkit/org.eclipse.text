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
module org.eclipse.text.edits.TreeIterationInfo;

import org.eclipse.text.edits.MultiTextEdit; // packageimport
import org.eclipse.text.edits.CopySourceEdit; // packageimport
import org.eclipse.text.edits.MoveSourceEdit; // packageimport
import org.eclipse.text.edits.CopyingRangeMarker; // packageimport
import org.eclipse.text.edits.ReplaceEdit; // packageimport
import org.eclipse.text.edits.EditDocument; // packageimport
import org.eclipse.text.edits.UndoCollector; // packageimport
import org.eclipse.text.edits.DeleteEdit; // packageimport
import org.eclipse.text.edits.MoveTargetEdit; // packageimport
import org.eclipse.text.edits.CopyTargetEdit; // packageimport
import org.eclipse.text.edits.TextEditCopier; // packageimport
import org.eclipse.text.edits.ISourceModifier; // packageimport
import org.eclipse.text.edits.TextEditMessages; // packageimport
import org.eclipse.text.edits.TextEditProcessor; // packageimport
import org.eclipse.text.edits.MalformedTreeException; // packageimport
import org.eclipse.text.edits.TextEditVisitor; // packageimport
import org.eclipse.text.edits.TextEditGroup; // packageimport
import org.eclipse.text.edits.TextEdit; // packageimport
import org.eclipse.text.edits.RangeMarker; // packageimport
import org.eclipse.text.edits.UndoEdit; // packageimport
import org.eclipse.text.edits.InsertEdit; // packageimport


import java.lang.all;
import java.util.Set;

import org.eclipse.core.runtime.Assert;


class TreeIterationInfo {

    interface Visitor {
        void visit(TextEdit edit);
    }

    private int fMark= -1;
    private TextEdit[][] fEditStack;
    private int[] fIndexStack;

    public this(){
        fEditStack= new TextEdit[][](10);
        fIndexStack= new int[10];
    }

    public int getSize() {
        return fMark + 1;
    }
    public void push(TextEdit[] edits) {
        if (++fMark is fEditStack.length) {
            TextEdit[][] t1= new TextEdit[][](fEditStack.length * 2);
            SimpleType!(TextEdit[]).arraycopy(fEditStack, 0, t1, 0, fEditStack.length);
            fEditStack= t1;
            int[] t2= new int[fEditStack.length];
            System.arraycopy(fIndexStack, 0, t2, 0, fIndexStack.length);
            fIndexStack= t2;
        }
        fEditStack[fMark]= edits;
        fIndexStack[fMark]= -1;
    }
    public void setIndex(int index) {
        fIndexStack[fMark]= index;
    }
    public void pop() {
        fEditStack[fMark]= null;
        fIndexStack[fMark]= -1;
        fMark--;
    }
    public void accept(Visitor visitor) {
        for (int i= fMark; i >= 0; i--) {
            Assert.isTrue(fIndexStack[i] >= 0);
            int start= fIndexStack[i] + 1;
            TextEdit[] edits= fEditStack[i];
            for (int s= start; s < edits.length; s++) {
                visitor.visit(edits[s]);
            }
        }
    }
}
