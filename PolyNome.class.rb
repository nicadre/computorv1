# coding: utf-8
$LOAD_PATH << '.'
require "MathTools.module"

class Polynome

    def		initialize(expression)
        puts "given expression: " + expression

        # destroy all spaces and replace , to .
        @expression = expression.gsub /\s/, '\1\2'
        @expression.gsub! ',', '.'
        @expression.gsub! 'x', 'X'

        # determinate if the entry contains only supported characters.
        abort("Parse error, this entry contains forbiden characters.") if ((@expression =~ /\A(X|\d|\+|-|\*|\^|\.)*=(X|\d|\+|-|\*|\^|\.)*\z/i).nil?) == true
        abort("Parse error, this entry contains coefficient after an x pow, only coefficients before x pow are supported.") unless ((@expression =~ /X\d/i).nil?) == true
        abort("Parse error, this entry contains an error with X coefficients.") unless ((@expression =~ /(x(\^\d+)?(\*|x(\^\d+)?|\*x(\^\d+)?){1})+/i).nil?) == true

        # deal with natural entry
        @expression.gsub! 'X^', 'Y'
        @expression.gsub! 'X', 'X^1'
        @expression.gsub! 'Y', 'X^'

        # deal with many +- operators
        while /[-\+]{2}/.match(@expression) != nil do
            while /\+-/.match(@expression) != nil do
                @expression.sub! /\+-/, '\1-\2'
            end
            while /-\+/.match(@expression) != nil do
                @expression.sub! /-\+/, '\1-\2'
            end
            while /--/.match(@expression) != nil do
                @expression.sub! /--/, '\1+\2'
            end
            while /\+\+/.match(@expression) != nil do
                @expression.sub! /\+\+/, '\1+\2'
            end
        end
        @expression.gsub! '-', '+-'
        @expression.gsub! '=+', '='
        @expression.sub! /^\+-/, '\1-\2'

        #detect if the given entry is well formated and if there is no possible bug with the entry
        abort("Parse error, this entry is not well formated or contained disable things") if ((@expression =~ /\A(-?\d*(\.\d+)?(\*?x(\^\d+)?)?\+?)+=(-?\d*(\.\d+)?(\*?x(\^\d+)?)?\+?)+\z/i).nil?) == true

        @coeff = Hash.new
        @delta = false
        #reduce the expression and store in reduced and coeff the found expression
        reduce
    end

    # Resolve the Polynome or display an error if it's too hard or can't be solved
    def		resolve()
        calculateDelta
        # delta is set as true => polynomial degree < 2
        if @delta == true
            if @coeff.length == 1 || @coeff[1] == 0
                puts "Reduced form: " + reduce_form
                puts "Polynomial degree: 0"
                unless @coeff[0] == 0
                    puts "0 can only be equal to 0!"
                    puts "there is no solution for this equation."
                else
                    puts "You prove that 0 = 0, congratulation."
                    puts "all real numbers can solve this equation."
                end
            else
                puts "Reduced form: " + reduce_form
                puts "Polynomial degree: 1"
                puts "the solution is:"
                puts "X = #{-@coeff[0]} / #{@coeff[1]}."
                puts "X = " + format_result((-1 * @coeff[0].to_f)/@coeff[1].to_f).to_s + "."
            end
            # delta is set as false => polynomial degree > 2 but it may have reduce_form which can be solved
        elsif @delta == false
            (@coeff.length - 1).downto(0) do |v|
                if @coeff[v] != 0
                    if v > 2
                        puts "Reduced form: " + reduce_form
                        puts "Polynomial degree: #{v}"
                        puts "The polynomial degree is stricly greater than 2, I can't solve."
                        break
                    else
                        tmp = Hash.new
                        v.downto(0) do |v2|
                            tmp[v2] = @coeff[v2]
                        end
                        @coeff = tmp
                        resolve
                        break
                    end
                elsif (v == 0)
                    @coeff = Hash.new
                    @coeff[0] = 0;
                    resolve
                    break
                end
            end
            # delta has been set and we have to calculate the solution(s) of the polynomial
        else
            puts "Reduced form: " + reduce_form
            puts "Polynomial degree: 2"
            puts "Δ = #{@coeff[1]}² - 4 * #{@coeff[2]} * #{@coeff[0]} = #{@delta}."
            if @delta == 0
                puts "Δ = 0, there is only one real solution:"
                puts "X = -#{@coeff[1]} / (2 * #{@coeff[2]})."
                puts "X = " + (-1 * @coeff[1]).to_s + " / " + (2 * @coeff[2]).to_s + "."
                puts "X = " + format_result((-1*@coeff[1].to_f).to_f/(2*@coeff[2].to_f).to_f).to_s + "."
            elsif @delta > 0
                puts "Δ > 0, there is two real solutions:"
                puts "X1 = (-#{@coeff[1]} + √#{@delta}) / (2 * #{@coeff[2]})."
                puts "X1 = (" + (-1 * @coeff[1]).to_s + " + " + get_delta_format() + ") / " + (2 * @coeff[2]).to_s + "."
                puts "X1 = " + format_result(((-1*@coeff[1].to_f) + MathTools.sqrt(@delta).to_f).to_f/(2*@coeff[2].to_f)).to_s + "."

                puts "X2 = (-#{@coeff[1]} - √#{@delta}) / (2 * #{@coeff[2]})."
                puts "X2 = (" + (-1 * @coeff[1]).to_s + " - " + get_delta_format() + ") / " + (2 * @coeff[2]).to_s + "."
                puts "X2 = " + format_result(((-1*@coeff[1].to_f) - MathTools.sqrt(@delta).to_f).to_f/(2*@coeff[2].to_f)).to_s + "."
            else
                puts "Δ < 0, there is no real solutions but two complexe solutions:"
                puts "X1 = -#{MathTools.abs(@coeff[1])} / (2 * #{@coeff[2]}) + i * ((√- #{@delta}) / (2 * #{@coeff[2]}))."
                puts "X1 = " + (-1 * @coeff[1]).to_s + " / " + (2 * @coeff[2]).to_s + " +  i * " + get_delta_format('negatif') + " / " + (2 * @coeff[2]).to_s + "."
                puts "X1 = " + format_result((-1*@coeff[1].to_f)/(2*@coeff[2].to_f)).to_s + get_imaginary_format()

                puts "X2 = -#{MathTools.abs(@coeff[1])} / (2 * #{@coeff[2]}) - i * ((√- #{@delta}) / (2 * #{@coeff[2]}))."
                puts "X2 = " + (-1 * @coeff[1]).to_s + " / " + (2 * @coeff[2]).to_s + " - i * " + get_delta_format('negatif') + " / " + (2 * @coeff[2]).to_s + "."
                puts "X2 = " + format_result((-1*@coeff[1].to_f)/(2*@coeff[2].to_f)).to_s + get_imaginary_format('negatif')
            end
        end
    end

    private

    # Get the well formated delta string
    def		get_delta_format(delta = 'positif')
        if delta == 'positif'
            if MathTools.sqrt(@delta) % 1 != 0
                s = "√#{@delta}"
            else
                s = MathTools.sqrt(@delta).to_s
            end
        else
            if MathTools.sqrt(-@delta) % 1 != 0
                s = "√- #{@delta}"
            else
                s = MathTools.sqrt(-@delta).to_s
            end
        end
        return s
    end

    # Get the well formated imaginary string
    def		get_imaginary_format(i = 'positif')
        if i == 'positif'
            s = " + " if MathTools.sqrt(-@delta).to_f/(2*@coeff[2].to_f) >= 0
            s = " - " unless MathTools.sqrt(-@delta).to_f/(2*@coeff[2].to_f) >= 0
        else
            s = " - " if MathTools.sqrt(-@delta).to_f/(2*@coeff[2].to_f) >= 0
            s = " + " unless MathTools.sqrt(-@delta).to_f/(2*@coeff[2].to_f) >= 0
        end
        if MathTools.sqrt(-@delta).to_f/(2*@coeff[2].to_f) % 1 != 0
            s = s + "i * " +  format_result(MathTools.sqrt(-@delta).to_f/(2*@coeff[2].to_f)).to_s + "."
        else
            if format_result(MathTools.sqrt(-@delta).to_f/(2*@coeff[2].to_f)) == 1
                s = s + "i."
            else
                s = s + format_result(MathTools.sqrt(-@delta).to_f/(2*@coeff[2].to_f)).to_s + "i."
            end
        end
        return s
    end

    # Get The string of the reduced form
    def		reduce_form()
        reduced = ""
        @coeff.each do |key, value|
            unless value == 0
                if (value < 0)
                    value = MathTools.abs(value)
                    reduced += "- "
                else
                    reduced = reduced + "+ " unless reduced.empty?
                end
                reduced += "#{value} * X^#{key} "
            end
        end
        reduced += "= 0"
        return reduced
    end

    def		calculate(operand, way = "lhs")
        operand.split('+').each do |value|
            value.strip!
            value.split('*').join
            tmp = value.split('X^')
            abort("parse error: missing left or right operand near 'X^'") if tmp.length == 1 and value.include?("X^")
            if tmp[1] == nil
                tmp[1] = '0'
            end
            tmp[1].to_s.strip!
            if (way == "rhs")
                if @coeff[tmp[1].to_i]
                    if (tmp[0].empty?)
                        @coeff[tmp[1].to_i] -= 1
                    else
                        @coeff[tmp[1].to_i] -= (tmp[0] == '-') ? -1 : tmp[0].to_f
                    end
                else
                    if (tmp[0].empty?)
                        @coeff[tmp[1].to_i] = -1
                    else
                        @coeff[tmp[1].to_i] = (tmp[0] == '-') ? 1 : -tmp[0].to_f
                    end
                end
            else
                if @coeff[tmp[1].to_i]
                    if (tmp[0].empty?)
                        @coeff[tmp[1].to_i] += 1
                    else
                        @coeff[tmp[1].to_i] += (tmp[0] == '-') ? -1 : tmp[0].to_f
                    end
                else
                    if (tmp[0].empty?)
                        @coeff[tmp[1].to_i] = 1
                    else
                        @coeff[tmp[1].to_i] = (tmp[0] == '-') ? -1 : tmp[0].to_f
                    end
                end
            end
        end
    end

    # Reduce the valid string to a hash table of coef and X pow
    def		reduce()
        splited = @expression.split('=')
        splited.each { |s| s.strip! }
        abort("parse error: multiple =") if splited.length > 2
        abort("parse error: missing operand near '='") if splited.length == 1

        # calculate left hand operand
        calculate(splited[0])

        # calculate right hand operand and substract coefficients to the left operand in @coeff
        calculate(splited[1], "rhs")

        @coeff.each do |k, v|
            @coeff[k] = format_result(v)
        end

        # fill the blanks by 0 values
        (@coeff.keys.max - 1).downto(0) do |v|
            unless @coeff.has_key? v
                @coeff[v] = 0
            end
        end
        @coeff = Hash[@coeff.sort.reverse]
    end

    # Math formula to determinate the value of delta
    def		calculateDelta()
        if @coeff.length > 3
            @delta = false
        elsif @coeff.length < 3 or (@coeff.length == 3 and @coeff[2] == 0)
            @delta = true
        else
            @delta = MathTools.square(@coeff[1]) - (4 * @coeff[2] * @coeff[0])
        end
    end

    # Convert result to int if it's possible
    def format_result(float)
        float.to_i == float ? float.to_i : float
    end
end
