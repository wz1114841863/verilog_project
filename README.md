## 介绍
Verilog 项目
## 代码规范
缩进: 使用4个空格

if语句:
```
if (a == 1'b1) begin  // 由begin…end包起来，并且begin在if/else之后
    c <= b;
end else begin
    c <= d;
end
```
case语句
```
case (a)
	1'b1: begin  // 由begin…end包起来，并且begin在匹配项之后
		c = b;
	end
	default: begin
		c = d;
	end
endcase
```
always语句
```
always @ (posedge clk) begin
    a <= b;
end
```
其他
```
=、==、<=、>=、+、-、*、/、@等符号左右各有一个空格。
,和:符号后面有一个空格。
对于模块的输入、输出信号，不省略wire、reg等关键字。
if、case、always后面都有一个空格。
每个文件的最后留一行空行。
```
