package decency.assembler;

import decency.assemInstr.*;
import java.util.*;

public class Assembler {
	List<String> binCode = new ArrayList<String>();
	List<AssemInstr> assemCode;
	int counter;
	Map<String, Integer> labelTable = new HashMap<String, Integer>();

	public Assembler(List<AssemInstr> l) {
		assemCode = l;
	}

	public List<String> binCodeGen() {
		counter = 0;
		for (AssemInstr ai : assemCode) {
			if (ai instanceof LABEL)
				labelTable.put(((LABEL) ai).label, counter);
			else
				++counter;
		}
		counter = 0;
		for (AssemInstr ai : assemCode) {
			if (ai instanceof LABEL)
				continue;
			else if (ai instanceof ADD)
				gen((ADD) ai);
			else if (ai instanceof MUL)
				gen((MUL) ai);
			else if (ai instanceof BGT)
				gen((BGT) ai);
			else if (ai instanceof BNEZ)
				gen((BNEZ) ai);
			else if (ai instanceof LW)
				gen((LW) ai);
			else if (ai instanceof SW)
				gen((SW) ai);
			else if (ai instanceof J)
				gen((J) ai);
			else if (ai instanceof MV)
				gen((MV) ai);
			else if (ai instanceof NOP)
				emit("");// NOP
			else if (ai instanceof HALT)
				emit("0001");
			else
				System.err.println("Undefined assemble instruction.");
			++counter;
		}
		return binCode;
	}

	void emit(String s) {
		String x = Util.widen(s, 32);
		binCode.add(x.substring(0, 8));
		binCode.add(x.substring(8, 16));
		binCode.add(x.substring(16, 24));
		binCode.add(x.substring(24, 32));
	}

	void gen(ADD ai) {
		if (ai.src2 instanceof Reg)
			emit("1000" + ai.dst.gen() + ai.src1.gen()
					+ ((Reg) (ai.src2)).gen());
		else
			emit("1000" + ai.dst.gen() + ai.src1.gen()
					+ Util.widen(((Imm) (ai.src2)).imm, 15) + "1");
	}

	void gen(MUL ai) {
		if (ai.src2 instanceof Reg)
			emit("1001" + ai.dst.gen() + ai.src1.gen()
					+ ((Reg) (ai.src2)).gen());
		else
			emit("1001" + ai.dst.gen() + ai.src1.gen()
					+ Util.widen(((Imm) (ai.src2)).imm, 15) + "1");
	}

	void gen(BGT ai) {
		emit("1010" + ai.src1.gen() + ai.src2.gen()
				+ Util.widen((labelTable.get(ai.label) - counter) * 4, 16));
	}

	void gen(BNEZ ai) {
		emit("1011" + ai.src.gen()
				+ Util.widen((labelTable.get(ai.label) - counter) * 4, 20));
	}

	void gen(LW ai) {
		if (ai.src2 instanceof Reg)
			emit("1100" + ai.dst.gen() + ai.src1.gen()
					+ ((Reg) (ai.src2)).gen());
		else
			emit("1100" + ai.dst.gen() + ai.src1.gen()
					+ Util.widen(((Imm) (ai.src2)).imm, 15) + "1");
	}

	void gen(SW ai) {
		if (ai.src2 instanceof Reg)
			emit("1101" + ai.dst.gen() + ai.src1.gen()
					+ ((Reg) (ai.src2)).gen());
		else
			emit("1101" + ai.dst.gen() + ai.src1.gen()
					+ Util.widen(((Imm) (ai.src2)).imm, 15) + "1");
	}

	void gen(J ai) {
		emit("1110" + Util.widen((labelTable.get(ai.label) - counter) * 4, 28));
	}

	void gen(MV ai) {
		if (ai.src instanceof Reg)
			emit("1111" + ai.dst.gen() + ((Reg) (ai.src)).gen());
		else
			emit("1111" + ai.dst.gen() + Util.widen(((Imm) (ai.src)).imm, 21)
					+ "1");
	}
}
