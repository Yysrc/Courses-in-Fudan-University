/*
运行命令：
g++ cachesim.cpp -o cachesim
./cachesim -c cfg.txt -t ls.trace -o ls.trace.out
*/

#include<iostream>
#include<fstream>
#include<string>
#include<cmath>
#include<iomanip>
using namespace std;

typedef struct Cache{
	unsigned long long tag;	//标记
	int cnt;				//计数器
	int V;					//有效位
	Cache() {				//构造函数
		tag = 0;
		cnt = 0;
		V = 0;
	}
} CacheLine;

CacheLine** Initialization(unsigned int groupSum, unsigned int associativity){
	//groupSum：组数目
	//associativity：关联度，直接映射为1，全相联映射为cache行数
	CacheLine** cache;
	cache = new CacheLine*[groupSum];
	for (int i = 0; i != groupSum; ++i) {
		cache[i] = new CacheLine[associativity]{};
	}
	return cache;
}

void Clean(CacheLine** cache, unsigned int groupSum){
	for(int i = 0; i != groupSum; ++i)
		delete[] cache[i];
	delete[] cache;
}

void CacheWorkLRU(CacheLine** cache, unsigned long long memTag,
	unsigned long long groupNum, int associativity, char readorWrite,
	int missCost, int writeMethod, int& hits, int& loadHits, int& storeHits, int& cycles) {
	//LRU替换

	CacheLine* line = cache[groupNum];

	//空行一定出现在所有非空行之后
	for (int i = 0; line[i].V == 1; ++i) {
		//命中
		if (memTag == line[i].tag) {
			//更新引用值
			hits++;
			cycles++;
			if (readorWrite == 'R') loadHits++;
			else if (readorWrite == 'W') storeHits++;
			//计数器变化
			for (int j = 0; line[j].V == 1; ++j) {
				if (line[j].cnt < line[i].cnt) {
					line[j].cnt++;
				}
			}
			line[i].cnt = 0;
			//若命中则返回
			return;
		}
	}

	//未命中
	cycles += missCost;			//用非命中开销更新周期数
	int evictionIndex = 0;		//空行索引
	int i = 0;
	int max = 0;
	for (i = 0; line[i].V == 1; ++i) {
		//计数位加1,记录可能的（若无空行）替换行的索引
		if (line[i].cnt > max) {
			max = line[i].cnt;
			evictionIndex = i;
		}
		line[i].cnt++;
	}

	if (i != associativity){
		//有空行
		if (readorWrite == 'R' || (readorWrite == 'W' && writeMethod == 1)) {
			//读操作，或写操作且全写法，更新cache
			line[i].V = 1;
			line[i].tag = memTag;
			line[i].cnt = 0;
		}
		return;
	}
	else {
		// 无空行
		if (readorWrite == 'R' || (readorWrite == 'W' && writeMethod == 1)) {
			//读操作，或写操作且全写法，更新cache
			line[evictionIndex].tag = memTag;
			line[evictionIndex].cnt = 0;
			line[evictionIndex].V = 1;
			return;
		}
	}
}


void CacheWorkRand(CacheLine** cache, unsigned long long memTag,
	unsigned long long groupNum, int associativity, char readorWrite,
	int missCost, int writeMethod, int& hits, int& loadHits, int& storeHits, int& cycles) {
	//随机替换
	CacheLine* line = cache[groupNum];

	for (int i = 0; line[i].V == 1; ++i) {
		//命中
		if (memTag == line[i].tag) {
			hits++;
			cycles++;
			if (readorWrite == 'R') loadHits++;
			else if (readorWrite == 'W') storeHits++;
			return;
		}
	}

	//未命中
	cycles += missCost;
	int evictionIndex = 0;
	int i = 0;
	for (i = 0; line[i].V == 1; ++i);

	if (i != associativity) {
		//有空行
		if (readorWrite == 'R' || (readorWrite == 'W' && writeMethod == 1)) {
			//读操作，或写操作且全写法，更新cache
			line[i].tag = memTag;
			line[i].V = 1;
		}
		return;
	}
	else {
		// 无空行
		if (readorWrite == 'R' || (readorWrite == 'W' && writeMethod == 1)) {
			//读操作，或写操作且全写法，更新cache
			evictionIndex = (rand() % associativity);
			line[evictionIndex].tag = memTag;
			line[evictionIndex].V = 1;
			return;
		}
	}
}

int main(int argc, char* argv[])
{
	ifstream fin;
	fin.open(argv[2]);
	if (!fin) {
		cout << "Cannot open file " << argv[2] << "!" << endl;
		exit(1);
	}
	int blockSize;						//块大小（B）
	unsigned int associativityMark;		//数据大小（KB）
	unsigned long dataSize;				//关联性标记，见配置文件定义
	int replaceMethod;					//替换方法
	int missCost;						//非命中开销
	int writeMethod;					//写入方法

	fin >> blockSize >> associativityMark >> dataSize
		>> replaceMethod >> missCost >> writeMethod;
	fin.close();

	int q, k;	//q：cache组号位数； k：块内地址位数

	unsigned int groupSum, associativity;

	k = (int)log2(blockSize);
	if (associativityMark != 0) {
		//直接映射（相当于每组1行）&组相联映射
		associativity = associativityMark;
		groupSum = dataSize * 1024 / blockSize / associativity;
		q = (int)log2(groupSum);
	}
	else {
		//全相联映射
		groupSum = 1;
		//关联度即为cache行数
		associativity = dataSize * 1024 / blockSize;
		q = 0;	//无组号,q设为0
	}

	CacheLine** cache = Initialization(groupSum, associativity);

	int hits = 0;
	int sum = 0;
	int loadHits = 0;
	int loadSum = 0;
	int storeHits = 0;
	int storeSum = 0;
	int cycles = 0;

	fin.open(argv[4]);
	if (!fin) {
		cout << "Cannot open file " << argv[4] << "!" << endl;
		exit(1);
	}

	while (fin) {
		string instructionAddr;
		char readorWrite;
		string dataAddr;
		fin >> instructionAddr >> readorWrite >> dataAddr;
		sum++;
		if (readorWrite == 'R') loadSum++;
		else storeSum++;

		if (instructionAddr == "#eof") break;
		unsigned long long addr = stoll(dataAddr, nullptr, 16);
		unsigned long long memTag = addr >> (q + k);
		//通过包含q和k的位运算得到memTag和groupNum
		unsigned long long groupNum = ((addr << (64 - q - k)) >> (64 - q));
		//虽然跟踪文件中地址是48位，但实际保存时是64位

		if (replaceMethod) {
			CacheWorkLRU(cache, memTag, groupNum, associativity, readorWrite,
				missCost, writeMethod, hits, loadHits, storeHits, cycles);
		}
		else {
			CacheWorkRand(cache, memTag, groupNum, associativity, readorWrite,
				missCost, writeMethod, hits, loadHits, storeHits, cycles);
		}
	}
	fin.close();
	
	ofstream ofs;
	ofs.open(argv[6], ios::out);

	ofs.setf(ios::fixed);
	ofs.precision(4);
	ofs << "Total Hit Rate: " << ((float)hits / sum * 100) << "%" << endl;
	ofs.precision(2);
	ofs << "Load Hit Rate: " << ((float)loadHits / loadSum * 100) << "%" << endl;
	ofs << "Store Hit Rate: " << ((float)storeHits / storeSum * 100) << "%" << endl;
	ofs << "Total Run Time: " << cycles << endl;
	ofs << "AVG MA Latency: " << ((float)cycles / sum) << endl;

	ofs.close();

	Clean(cache, groupSum);
	return 0;
}
