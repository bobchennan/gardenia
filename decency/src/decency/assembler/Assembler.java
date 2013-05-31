package decency.assembler;

import decency.assemInstr.*;
import java.util.*;

public class Assembler {
	List<String> binCode = new ArrayList<String>();
	List<AssemInstr> assemCode;

	public Assembler(List<AssemInstr> l) {
		assemCode = l;
	}
}
