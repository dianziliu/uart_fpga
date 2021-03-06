library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity uart is
port(uart_in:in std_logic_vector(7 downto 0);
	 uart_out:out std_logic_vector(7 downto 0);
	 rx:in std_logic;  --shou
	 tx:out std_logic; --fa
	 clk:in std_logic;
	 en:in std_logic ; --shineng
	 rw:in std_logic); --shoufakongzhi
end uart;

architecture beh of uart is
--signal f:std_logic; --shou
signal e:std_logic; --fa

signal see:std_logic;
signal clk_see:std_logic;
signal clk_see_count:integer;
signal see_data:std_logic_vector(2 downto 0);

signal uart_count:integer;
signal uart_dount:integer;

signal clk_uart:std_logic;
signal clk_uart_count:integer;

signal out_count:std_logic_vector(7 downto 0);
signal in_count:std_logic_vector(7 downto 0);

type state is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12);
signal get:state;
signal send:state;
begin

--see_clk
process(clk,en,see)
	begin
	 if(en='1' and see='0')then
		if(clk='1'and clk'event)then
		if(clk_see_count=50000000/9600/2/3)then
			clk_see<=not clk_see;
			clk_see_count<=0;
			else
			clk_see_count<=clk_see_count+1;
			end if;
	end if;
	end if;
	end process;
--see and get
	process(clk_see,see)
	begin
	  if(clk_see='1'and clk_see'event)then
		if(see='0')then
		see_data(2)<=see_data(1);
		see_data(1)<=see_data(0);
		see_data(0)<=rx;
		if(see_data="100")then
		see<='1';
		end if;
		end if;
		if(uart_count=2)then
		 if(see='1')then
			case get is
		when s0=> in_count(7)<=rx;get<=s1;
		when s1=> in_count(6)<=rx;get<=s2;
		when s2=> in_count(5)<=rx;get<=s3;
		when s3=> in_count(4)<=rx;get<=s4;
		when s4=> in_count(3)<=rx;get<=s5;
		when s5=> in_count(2)<=rx;get<=s6;
		when s6=> in_count(1)<=rx;get<=s7;
		when s7=> in_count(0)<=rx;get<=s8;
		when s8=> see<='0';get<=s0;
		when others=> get<=s0;
		end case;
		end if;
		uart_count<=0;
		else
		uart_count<=uart_count+1;	
		end if;	
	end if;
	uart_out<=in_count;
	end process;	
-- out
process(clk_see,clk_uart,e)
begin	
	if(clk_uart='1'and clk_uart'event)then
	if(e='0')then
	out_count<=uart_in;
	e<='1';
	end if;
	if(e='1')then
	 case send is
	when s0 =>tx<='0';send<=s1;
	when s1 =>tx<=out_count(7);send<=s2;
	when s2 =>tx<=out_count(6);send<=s3;
	when s3 =>tx<=out_count(5);send<=s4;
	when s4 =>tx<=out_count(4);send<=s5;
	when s5 =>tx<=out_count(3);send<=s6;
	when s6 =>tx<=out_count(2);send<=s7;
	when s7 =>tx<=out_count(1);send<=s8;
	when s8 =>tx<=out_count(0);send<=s9;
	when s9 =>tx<=out_count(7);send<=s10;--jiaoyan
	when s10 =>tx<='1';send<=s11;
	when s11 =>tx<='1';send<=s12;
	when s12 =>e<='0';send<=s0;
	when others =>tx<='1';send<=s0;
	end case;
	end if;
		
	
end if;
end process;
--send clk		
process(rw,en,clk)
		begin
	if(rw='1'and en='1')then
		if(clk='1'and clk'event)then
		  if(clk_uart_count=50000000/9600/2)then
			clk_uart<=not clk_uart;
			clk_uart_count<=0;
			else
			clk_uart_count<=clk_uart_count+1;
			end if;
			end if;
		end if;
		end process;
		
end beh;