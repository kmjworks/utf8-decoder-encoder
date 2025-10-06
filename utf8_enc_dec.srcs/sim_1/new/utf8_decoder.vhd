library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;

entity utf8_decoder is port(
        clk                 : in std_logic;
        rst                 : in std_logic;
        
        -- Next byte in the UTF-8 text
        in_byte             : in std_logic_vector(7 downto 0);
        in_valid            : in std_logic;
        in_ready            : out std_logic;
        
        -- decoded code point pointing to a unique Unicode char
        out_codepoint       : out std_logic_vector(20 downto 0);
        out_valid           : out std_logic;
        out_ready           : in std_logic;
        
        err_unexp_lead_b    : out std_logic; -- lead byte while expecting continuation
        err_unexp_cont_b    : out std_logic; -- continuation byte while expecting lead
        err_utf16_surrogate : out std_logic; -- invalid surrogate codepoint
        err_invalid_val_b   : out std_logic; -- byte value that never appears in UTF-8
    );
end utf8_decoder;

architecture rtl of utf8_decoder is
    signal bytes_left : integer range 0 to 3;
    
begin
    in_ready <= not out_valid or out_ready;

DECODER_PROC : process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then 
            out_codepoint <= (others => '0');
            out_valid <= '0';
            err_unexp_lead_b <= '0';
            err_unexp_cont_b <= '0';
            err_utf16_surrogate <= '0';
            err_invalid_val_b <= '0';
            bytes_left <= 0;
        else
            -- Only release out_valid when the receiver accepts the word
            if out_ready = '1' then
                out_valid <= '0';
             end if;

             -- New input byte
             if in_valid = '1' and in_ready = '1' then
                err_unexp_lead_b <= '0';
                err_unexp_cont_b <= '0';
                err_utf16_surrogate <= '0';
                err_invalid_val_b <= '0';

                if in_byte(7 downto 6) = "10" then -- continuation

                    if bytes_left = 0 then
                        err_unexp_cont_b <= '1';
                    else
                        out_codepoint <= out_codepoint(14 downto 0) & in_byte(5 downto 0);
                        bytes_left <= bytes_left - 1;

                        if bytes_left = 1 then
                            out_valid < '1';
                        -- Lead byte 0xED
                        elsif bytes_left = 2 and out_codepoint(3 downto 0) = x"D" then
                            -- check whether the cont byte is 0xA0 or higher
                            if in_byte(7 downto 5) = "101" then
                                err_utf16_surrogate <= '1';
                                bytes_left <= 0;
                            end if;
                        end if;

                    end if;

                else -- lead byte
                    bytes_left <= 0;

                    if (bytes_left > 0) then
                        err_unexp_lead_b <= '1';
                    end if;
             
        end if;
    end if;

end process;

end rtl;